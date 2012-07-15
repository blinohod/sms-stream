#!/usr/bin/env perl 

use 5.8.0;
use strict;
use warnings;

use mro 'c3';

use FindBin;
use lib "$FindBin::Bin/../lib";

use base 'Colibri::App';

use Time::HiRes qw(sleep time);
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

__PACKAGE__->debug(1);

__PACKAGE__->run_app(
	conf_file => './sms-stream.conf',
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

# DLR URL base: http://127.0.0.1/stream/dlr-recv
# Params: msgid=$msgid&smsid=%F&from=%p&to=%P&time=%t&unixtime=%T&dlr=%d&dlrmsg=%A&meta=%D
sub process_dlr {

	my ($this) = @_;

	# Parse HTTP request from Kannel
	my %dlr = $this->kannel->receive( $this->cgi() );
	$this->trace( 'DLR received: %s', Dumper( \%dlr ) );

	unless ( keys %dlr ) {
		$this->log( 'error', 'Wrong HTTP request retrieved (should be DLR).' );
		return;
	}

	my $msg_id = $dlr{msgid};                           # original message ID to process
	my $mt_sm  = $this->cme->msg_get_by_id($msg_id);    # Original MT SM in queue
	$this->trace( 'Original MT SM %s', Dumper($mt_sm) );

	unless ($mt_sm) {
		$this->log( 'error', 'No MT SM found with ID=%s', $msg_id );
		return;
	}

	my $dlr_state = '';                                 # Status to be set in generated DLR message
	my $mt_status = '';                                 # Status to be set in message storage
	my $err_code  = 0;                                  # GSM error code

	if ( $dlr{dlr_state} == Colibri::Kannel::STATE_DELIVERED ) {

		$dlr_state = 'DELIVRD';
		$mt_status = 'DELIVERED';

	} elsif ( $dlr{dlr_state} == Colibri::Kannel::STATE_REJECTED ) {

		$dlr_state = 'REJECTD';
		$mt_status = 'REJECTED';

	} elsif ( $dlr{dlr_state} == Colibri::Kannel::STATE_UNDELIVERABLE ) {

		$dlr_state = 'UNDELIV';
		$mt_status = 'UNDELIVERABLE';

		# Kannel provides "undeliverable" state for both UNDELIV and EXPIRED
		# To separate these states we try to parse message body
		if ( $dlr{dlr_msg} =~ /EXPIRED/ ) {
			$dlr_state = 'EXPIRED';
			$mt_status = 'EXPIRED';
		}

	}

	# Generate DLR message
	$this->log( 'info', 'Generating DLR for MT SM (%s): state=%s', $msg_id, $dlr_state );
	$this->cme->create_dlr(
		$mt_sm,
		date_sub => $mt_sm->{created},
		status   => $dlr_state,
		err      => $err_code,
	);

	$this->log( 'info', 'Set new status to MT SM (%s): status=%s', $msg_id, $mt_status );
	$this->cme->msg_update(
		$msg_id,
		status => $mt_status,
	);

} ## end sub process_dlr

1;
