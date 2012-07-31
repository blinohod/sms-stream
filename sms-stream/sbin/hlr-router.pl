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

__PACKAGE__->run_app(
	conf_file => '/opt/sms-stream/etc/sms-stream.conf',
	pid_file  => '/var/run/hlr-router.pid',
	daemon    => 1,
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
				$this->process_message($msg);
			}
		} else {
			sleep 1;    # FIXME
		}

	}

}

sub process_message {

	my ( $this, $msg ) = @_;

	my $msisdn = $msg->{dst_addr};

	my $app_kannel_id = $this->cme->get_app_id('app_kannel');

	# Looking for prefix based direction.
	my $dir = $this->cme->find_direction($msisdn);

	# Direction is not found by prefix.
	# Possibly wrong MSISDN or missed record in "stream.directions" table.
	unless ($dir) {

		$this->cme->create_dlr(
			$msg,
			date_sub => $msg->{created},
			status   => 'REJECTD',
		);

		$this->cme->msg_update(
			$msg->{id},
			status => 'REJECTED',
		);

		return 1;
	}

	$this->log( 'debug', 'Found prefix: MSISDN %s => MNO %s', $msisdn, $dir->{mno_id} );

	# For this direction HLR lookup is not supported.
	# Route by MSISDN prefix only.
	unless ( $dir->{use_hlr} ) {

		$this->log( 'info', 'HLR lookup not required for direction: MSISDN %s', $msisdn );

		my $smsc_id = $this->cme->route_by_mno( $dir->{mno_id} );
		if ($smsc_id) {
			$this->cme->msg_update(
				$msg->{id},
				mno_id     => $dir->{mno_id},
				smsc_id    => $smsc_id,
				status     => 'ROUTED',
				dst_app_id => $app_kannel_id,
			);
		} else {

			$this->cme->create_dlr(
				$msg,
				date_sub => $msg->{created},
				status   => 'UNDELIV',
			);

			$this->cme->msg_update(
				$msg->{id},
				status => 'FAILED',
			);
		}
		return 1;

	} ## end unless ( $dir->{use_hlr} )

	# Route by cached MNO ID.
	if ( my $cached = $this->cme->hlr_find_cached($msisdn) ) {

		$this->log( 'info', 'Found entry in HLR lookup cache for MSISDN %s', $msisdn );
		$this->trace('HLR lookup cached data: %s', Dumper($cached));

		# Process invalid MSISDN
		unless ( $cached->{valid} ) {

			$this->cme->create_dlr(
				$msg,
				date_sub => $msg->{created},
				status   => 'UNDELIV',
			);

			$this->cme->msg_update(
				$msg->{id},
				status => 'FAILED',
			);
		}

		my $smsc_id = $this->cme->route_by_mno( $cached->{mno_id} );

		if ($smsc_id) {
			$this->cme->msg_update(
				$msg->{id},
				smsc_id    => $smsc_id,
				mno_id     => $cached->{mno_id},
				status     => 'ROUTED',
				dst_app_id => $app_kannel_id,
			);
		} else {
			$this->cme->msg_update(
				$msg->{id},
				status => 'FAILED',
			);
		}
		return 1;

	} ## end if ( my $cached = $this...)

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
	my $res = $this->hlr->send(
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
