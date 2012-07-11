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

1;

sub post_initialize_hook {

	my ($this) = @_;

	$this->dbh( Colibri::DBI->get_dbh( %{ $this->conf->{db} } ) );
	$this->cme( Colibri::CME->new( dbh => $this->dbh ) );
	$this->hlr( Colibri::Kannel->new( %{ $this->conf->{hlr} } ) );

}

sub get_event {

	my ($this) = @_;

	# Return to this point if no new messages in queue
	FETCH_MSG:

	# Seems we have signal for exit
	unless ( $this->{_continue_processing} ) {
		return undef;
	}

	my (@msgs) = $this->cme->fetch( 'app_hlr', 'NEW', 1 );

	if (@msgs) {
		$this->trace( "New messages fetched." . Dumper( \@msgs ) );
		return \@msgs;
	} else {

		sleep 1;
		goto FETCH_MSG;

	}

} ## end sub get_event

sub process {

	my ( $this, $msgs ) = @_;

	# Check if HLR lookup needed
	foreach my $msg (@$msgs) {

		my $msisdn = $msg->{dst_addr};
		$this->trace("Routing for MSISDN: $msisdn");

		if ( my $dir = $this->cme->find_direction($msisdn) ) {

			$this->trace("Prefix found");

			# Check if HLR request is required
			if ( $dir->{use_hlr} ) {

				# Send HLR request
				$this->hlr_request($msg);

			} else {

				$this->trace("Route by direction: MSISD " . $msisdn . " to MNO " . " $dir->{mno_id}");

				# Route by prefix
				$this->cme->route_to_mno( $msg, $dir->{mno_id} );

			}

		} else {

			# Set failed state (no direction)
			$this->cme->make_fail_reply($msg);

		}

	} ## end foreach my $msg (@$msgs)

} ## end sub process

sub hlr_request {

	my ( $this, $msg ) = @_;

	if ( my $cached = $this->cme->hlr_find_cached( $msg->{dst_addr} ) ) {

		$this->cme->route_by();
	} else {

		$this->trace("No MSISDN in HLR cache - prepare query");

		# Send HLR lookup query using SMPP
		my $res = $this->kannel->send(
			from     => $msg->{src_addr},
			to       => $msg->{dst_addr},
			text     => '',
			smsc     => $this->conf->{hlr}->{smsc},    # Dedicated SMSC for HLR Lookup
			dlr_mask => 3,                             # Successful and unsuccessful
			dlr_id   => $msg->{id},
		);

		$this->trace( "Return from Kannel HLR: " . $res );

	}

} ## end sub hlr_request

