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
#use Colibri::HLR;

# Debug and development
use Data::Dumper;

__PACKAGE__->mk_accessors(
	'dbh',       # DBI connection
	'cme',       # CME API
	'kannel',    # Kannel API
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
	$this->kannel( Colibri::Kannel->new( %{ $this->conf->{hlr} } ) );

}

sub get_event {

	my ($this) = @_;

	# Seems we have signal for exit
	unless ( $this->{_continue_processing} ) {
		return undef;
	}

	# Return to this point if no new messages in queue
	FETCH_MSG:

	my (@msgs) = $this->cme->fetch( 'app_hlr', 'ROUTED', 1 );

	if (@msgs) {
		return \@msgs;
	} else {

		if ( $this->{_continue_processing} ) {
			warn "Sleep\n";
			sleep 1;
			goto FETCH_MSG;
		}

	}

} ## end sub get_event

sub process {

	my ( $this, $msgs ) = @_;

	# Check if HLR lookup needed
	foreach my $msg (@$msgs) {

		my $msisdn = $msg->{dst_addr};
		$this->trace("MSISDN: $msisdn");

		if ( my $dir = $this->cme->find_direction($msisdn) ) {

			# Check if HLR request is required
			if ( $dir->{use_hlr} ) {

				# Send HLR request
				$this->hlr_request($msg);

			} else {

				# Route by prefix
				$this->route_to_mno( $msg, $dir->{mno_id} );

			}

		} else {

			# Set failed state (no direction)
			$this->fail_msg($msg);

		}

	} ## end foreach my $msg (@$msgs)

} ## end sub process

sub hlr_request {

	my ( $this, $msg ) = @_;

	my ($cached) = $this->dbh->selectrow_hashref("select * from stream.hlr_cache where msisdn = ? and expire > now()");
	$this->trace("Search in HLR lookup cache" . Dumper($cached));


}

