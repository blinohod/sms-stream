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
	'dbh',       # DBI connection
	'cme',       # CME API
	'kannel',    # kannel API
);

__PACKAGE__->run_app(
	conf_file => '/opt/sms-stream/etc/sms-stream.conf',
	pid_file  => '/var/run/kannel-sender.pid',
	daemon    => 1,
);

sub start_hook {

	my ($this) = @_;

	$this->dbh( Colibri::DBI->get_dbh( %{ $this->conf->{db} } ) );
	$this->cme( Colibri::CME->new( dbh => $this->dbh ) );
	$this->kannel( Colibri::Kannel->new( %{ $this->conf->{kannel} } ) );

}

sub process {

	my ($this) = @_;

	my $period = 5;

	while (1) {

		my $started = time();
		$this->trace( 'Started iteration time: %s', $started );

		my @links = $this->cme->get_active_smsc();

		foreach my $smsc (@links) {

			#$this->trace( 'Processing SMSC: %s', Dumper($smsc) );
			$this->log( 'debug', 'Processing SMSC: %s (bandwidth=%s)', $smsc->{name}, $smsc->{bandwidth} );

			my @msgs = $this->cme->msg_fetch_outgoing( 'app_kannel', $smsc->{id}, $smsc->{bandwidth} * $period );
			if (@msgs) {

				foreach my $msg (@msgs) {

					my $res = $this->send_message( $msg, $smsc->{name} );

					if ($res) {

						# Determine cost of MT SM
						my $rate = $this->cme->get_rate( $msg->{customer_id}, $msg->{mno_id} ) + 0;
						$this->trace( 'MT SM cost determined: (customer_id=%s, mno_id=%s) => %s', $msg->{customer_id}, $msg->{mno_id}, $rate );

						$this->cme->msg_update(
							$msg->{id},
							status => 'SENT',
							cost   => $rate,
						);

					} else {

						# Generate DLR
						$this->cme->create_dlr(
							$msg,
							status => 'REJECTD',    # Rejected by Kannel
							err    => 34,           # EC_SYSTEM_FAILURE
						);

						# Update MT SM status
						$this->cme->msg_update(
							$msg->{id},
							status => 'FAILED',
						);

					}

				} ## end foreach my $msg (@msgs)

			} ## end if (@msgs)

		} ## end foreach my $smsc (@links)

		# Sleep until end of iteration period
		if ( ( time() - $started ) lt $period ) {
			sleep( $started + $period - time() );
		}

	} ## end while (1)

} ## end sub process

sub send_message {

	my ( $this, $msg, $smsc ) = @_;

	$this->trace( 'Send new message: %s', Dumper($msg) );

	# Convert binary message from HEX to URI
	if ( $msg->{coding} == 1 ) {
		$msg->{body} = str_to_uri( hex_to_str( $msg->{body} ) );
	}

	# Convert UDH to byte string
	if ( $msg->{udh} ) {
		$msg->{udh} = hex_to_str( $msg->{udh} );
	}

	# Number of retries in case of HTTP failure
	my $tries_left = $this->conf->{kannel}->{retry_number} + 0;
	$tries_left ||= 1;

	# How long to wait between failures
	my $retry_timeout = $this->conf->{kannel}->{retry_timeout} + 0;
	$retry_timeout ||= 10;

	while ($tries_left) {
		# Send MT SM via Kannel
		my $res = $this->kannel->send(
			from     => $msg->{src_addr},
			to       => $msg->{dst_addr},
			text     => $msg->{body},
			coding   => $msg->{coding},
			udh      => $msg->{udh},
			charset  => 'UTF-8',
			mclass   => $msg->{mclass},
			smsc     => $smsc,              # SMSC identifier
			dlr_mask => 3,                  # Successful and unsuccessful
			dlr_id   => $msg->{id},
		);

		# Success
		if ($res) {
			$this->trace( 'Kannel request succeed: %s', $res );
			return $res;
		}

		$this->trace( 'Kannel request failed: %s', $this->kannel->errcode() );

		# No reason to resend if 4XX code retrieved
		if ( $this->kannel->errcode() =~ /4\d\d/ ) {
			return undef;
		}

		$tries_left--;
		sleep $retry_timeout;

		$this->trace( 'Left %s retries', $tries_left );

	} ## end while ($tries_left)

} ## end sub send_message

1;
