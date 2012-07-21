#!/usr/bin/env perl 

use 5.8.0;
use strict;
use warnings;

use mro 'c3';

use FindBin;
use lib "$FindBin::Bin/../lib";

use base 'Colibri::App';

use Colibri::Utils;
use Colibri::DBI;
use Colibri::CME;
use Colibri::Kannel;

use CGI::Fast;

# Debug and development
use Data::Dumper;

__PACKAGE__->mk_accessors(
	'dbh',       # DBI connection
	'cme',       # CME API
	'cgi',       # CGI.pm API
	'kannel',    # Kannel API
);

__PACKAGE__->run_app(
	conf_file => '/opt/sms-stream/etc/sms-stream.conf',
);

sub start_hook {

	my ($this) = @_;

	$this->dbh( Colibri::DBI->get_dbh( %{ $this->conf->{db} } ) );
	$this->cme( Colibri::CME->new( dbh => $this->dbh ) );
	$this->kannel( Colibri::Kannel->new() );

}

sub process {

	my ($this) = @_;

	while ( $this->cgi( CGI::Fast->new() ) ) {
		$this->process_dlr();
		print $this->cgi->header(
			-status => '200 OK',
			-type   => 'text/plain',
		);
		print "Accepted\n";
	}

}

# DLR URL base: http://127.0.0.1/stream/hlr-recv
# Params: msgid=$msgid&smsid=%F&from=%p&to=%P&time=%t&unixtime=%T&dlr=%d&dlrmsg=%A&meta=%D
#
# DLR body (successful):
# addr: 0 0 38591xxxxxxx addr: 0 0 0000000000 msg: id:40072910491427628 sub:001 dlvrd:001 submit date:1007291049 done date:1007291049 stat:DELIVRD err:000 IMSI:219101100935850 MSC:38591016 HLR:38591xxxxxxx ORN:VipNet PON:VipNet RON:VipNet ROC:HR MCCMNC:21910
#
# DLR body (error):
# addr: 0 0 385915369423 addr: 0 0 0000000000 msg: id:40072910491419819 sub:001 dlvrd:001 submit date:1007291049 done date:1007291049 stat:UNDELIV err:001 IMSI: MSC: ORN:VipNet MCCMNC:
sub process_dlr {

	my ($this) = @_;

	my $app_kannel_id = $this->cme->get_app_id('app_kannel');

	# Parse HTTP request from Kannel
	my %hlr = $this->kannel->receive( $this->cgi() );
	$this->log( 'info', 'HLR lookup data received: %s', Dumper( \%hlr ) );
	$this->trace( 'HLR lookup data received: %s', Dumper( \%hlr ) );

	unless ( keys %hlr ) {
		$this->log( 'error', 'Incorrect data retrieved to HLR receiver' );
		return;
	}

	my $msg_id = $hlr{msgid};                           # original message ID to process
	my $mt_sm  = $this->cme->msg_get_by_id($msg_id);    # Original MT SM in queue
	$this->trace( 'Original MT SM %s', Dumper($mt_sm) );

	unless ($mt_sm) {
		$this->log( 'error', 'No MT SM found with ID=%s', $msg_id );
		return;
	}

	my $msisdn = $mt_sm->{dst_addr};                    # MSISDN (represented as src-addr)

	my $imsi = '';
	my ( $mcc, $mnc ) = ( 0, 0 );

	if ( $hlr{dlr_state} == Colibri::Kannel::STATE_DELIVERED ) {

		if ( $hlr{dlr_msg} =~ /IMSI:\s*(\d+)/ ) {
			$imsi = $1;
		}

		if ( $hlr{dlr_msg} =~ /MCCMNC:\s*(\d\d\d)(\d+)/ ) {
			$mcc = $1;
			$mnc = $2;
		}

		# Store new HLR lookup data
		$this->cme->hlr_store(
			$msisdn,
			valid => 1,        # MSISDN is valid, messages allowed here
			imsi  => $imsi,    # SIM card ID
			mcc   => $mcc,     # Mobile Country Code
			mnc   => $mnc,     # Mobile Network Code
		);

		# Find destination SMSC
		my $smsc_id = $this->cme->route_by_mccmnc( $mcc, $mnc );

		if ($smsc_id) {
			$this->cme->msg_update(
				$msg_id,
				status     => 'ROUTED',
				smsc_id    => $smsc_id,
				dst_app_id => $app_kannel_id,
			);
		} else {
			$this->cme->create_dlr( $mt_sm, status => 'UNDELIV', );
			$this->cme->msg_update(
				$msg_id,
				status => 'FAILED',
			);
		}

	} elsif ( $hlr{dlr_state} == Colibri::Kannel::STATE_UNDELIVERABLE ) {

		$this->log( 'info', 'HLR lookup returned wrong MSISDN (%s)', $msisdn );

		$this->cme->create_dlr( $mt_sm, status => 'UNDELIV', );
		$this->cme->msg_update( $msg_id, status => 'UNDELIVERABLE', );
		$this->cme->hlr_store( $msisdn, valid => 0, );

	} else {

		$this->cme->create_dlr( $mt_sm, status => 'UNDELIV', );
		$this->cme->msg_update( $msg_id, status => 'UNDELIVERABLE', );

	}

} ## end sub process_dlr

1;
