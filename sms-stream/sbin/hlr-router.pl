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

# Debug and development
use Data::Dumper;

__PACKAGE__->mk_accessors(
	'dbh',    # DBI connection
	'cme',    # CME API
	'hlr',    # HLR via kannel API
);

__PACKAGE__->debug(1);

__PACKAGE__->run_app(
	conf_file => './sms-stream.conf',
);

sub start_hook {

	my ($this) = @_;

	$this->dbh( Colibri::DBI->get_dbh( %{ $this->conf->{db} } ) );
	$this->cme( Colibri::CME->new( dbh => $this->dbh ) );
	$this->hlr( Colibri::Kannel->new( %{ $this->conf->{hlr} } ) );

}

sub process {

	my ($this) = @_;

	while (1) {
		my (@msgs) = $this->cme->msg_fetch( 'app_hlr', 'NEW', 1 );
		if (@msgs) {
			foreach my $msg (@msgs) {
				$this->process_msg($msg);
			}
		} else {
			sleep 1;    # FIXME
		}

	}

}

sub process_message {

	my ( $this, $msg ) = @_;

	my $msisdn = $msg->{dst_addr};

	# Looking for prefix based direction
	my $dir = $this->cme->find_direction($msisdn);

	# Set failed state (no direction)
	unless ($dir) {
		#$this->cme->make_fail_reply($msg);
		return 1;
	}

	$this->log( 'debug', 'Found prefix: MSISDN %s => MNO %s', $msisdn, $dir->{mno_id} );

	# Route by prefix without HLR lookup
	unless ( $dir->{use_hlr} ) {

		$this->log( 'debug', 'HLR lookup not required for direction: MSISDN %s', $msisdn );
		$this->cme->route_by_mno( $msg, $dir->{mno_id} );
		return 1;

	}

	# Route by cached MNO ID
	if ( my $cached = $this->cme->hlr_find_cached($msisdn) ) {

		$this->cme->route_by_mno( $msg, $cached->{mno_id} );
		return 1;

	}

	# Send HLR lookup query via Kannel
	$this->trace("No MSISDN in HLR cache - prepare query");

	$this->send_hlr_query($msg);
	$this->cme->msg_update(
		$msg->{id},
		status => 'PROCESSING',
	);

} ## end sub process_message

sub send_hlr_query {

	my ( $this, $msg ) = @_;

	# Send HLR lookup query using SMPP
	my $res = $this->kannel->send(
		from     => 'lookup',
		to       => $msg->{dst_addr},
		text     => 'lookup',
		smsc     => $this->conf->{hlr}->{smsc},    # Dedicated SMSC for HLR Lookup
		dlr_mask => 3,                             # Successful and unsuccessful
		dlr_id   => $msg->{id},
	);

	$this->log( 'debug', 'Return from Kannel HLR: %s', $res );

}

1;
