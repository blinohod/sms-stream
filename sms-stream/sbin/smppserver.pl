#!/usr/bin/env perl 

use 5.8.0;
use strict;
use warnings;
use diagnostics -traceonly;

use mro 'c3';

use FindBin;
use lib "$FindBin::Bin/../lib";

use base 'Colibri::App';

use IO::Select;
use IO::Socket::INET;
use Net::SMPP;
use Time::HiRes qw(sleep time);
use JSON;
use IPC::ShareLite qw ( :lock );

use Colibri::Utils;
use Colibri::CME;
use Colibri::DBI;

# Debug and development
use Data::Dumper;

use constant AUTH_TIMEOUT => 10;    # Unauthenticated ESME must be disconnected after this timeout
use constant ACK_TIMEOUT  => 10;    # If no reply - disconnect

use constant ROLE_TRANSCEIVER => 'transceiver';
use constant ROLE_TRANSMITTER => 'transmitter';
use constant ROLE_RECEIVER    => 'receiver';

# SMPP PDU command_id table
use constant CMD_TAB => {
	0x80000000 => 'generic_nack',
	0x00000001 => 'bind_receiver',
	0x80000001 => 'bind_receiver_resp',
	0x00000002 => 'bind_transmitter',
	0x80000002 => 'bind_transmitter_resp',
	0x00000003 => 'query_sm',
	0x80000003 => 'query_sm_resp',
	0x00000004 => 'submit_sm',
	0x80000004 => 'submit_sm_resp',
	0x80000005 => 'deliver_sm_resp',
	0x00000006 => 'unbind',
	0x80000006 => 'unbind_resp',
	0x00000007 => 'replace_sm',
	0x80000007 => 'replace_sm_resp',
	0x00000008 => 'cancel_sm',
	0x80000008 => 'cancel_sm_resp',
	0x00000009 => 'bind_transceiver',
	0x80000009 => 'bind_transceiver_resp',
	0x0000000b => 'outbind',
	0x00000015 => 'enquire_link',
	0x80000015 => 'enquire_link_resp',
};

use constant STATUS_TAB => {
	ESME_ROK         => 0x00,    # No Error
	ESME_RINVMSGLEN  => 0x01,    # Message Length is invalid
	ESME_RINVCMDLEN  => 0x02,    # Command Length is invalid
	ESME_RINVCMDID   => 0x03,    # Invalid Command ID
	ESME_RINVBNDSTS  => 0x04,    # Incorrect BIND Status for given command
	ESME_RALYBND     => 0x05,    # ESME Already in Bound State
	ESME_RINVPASWD   => 0x0E,    # Invalid Password
	ESME_RSUBMITFAIL => 0x45,    # submit_sm or submit_multi failed
};

my $ESME = {};                   # ESME descriptors hash reference

__PACKAGE__->mk_accessors(
	'dbh',                       # DBI handler
	'cme',                       # Core Messaging Engine
	'listener',                  # Listering TCP socket for SMPP connections
	'selector',                  # IO::Select handler
	'role',                      # Program role ('smppd' or 'qproc')
	'shm',                       # Shared memory segment
	'link_smppd',
	'link_qproc',
);

__PACKAGE__->run_app(
	conf_file        => '/opt/sms-stream/etc/sms-stream.conf',    # configuration file
	pid_file         => '/var/run/smppserver.pid',
	daemon           => 1,
	smpp_listen_addr => '0.0.0.0',                                # all interfaces
	smpp_listen_port => 2775,                                     # defult SMPP port by IANA
);

1;

# ****************************************************************
# Processing subroutines

sub process {

	my ($this) = @_;

	if ( $this->role eq 'smppd' ) {
		$this->process_smppd();
	} else {
		$this->process_qproc();
	}

}

sub process_qproc {

	my ($this) = @_;

	while (1) {

		$this->trace('MO queue process iteration');

		foreach my $customer_id ( keys %{ $this->shm_read() } ) {
			$this->log( 'debug', 'Processing queue for customer id=%s', $customer_id );
			$this->link_qproc->print("Data\n");
		}

		sleep 1;

	}

}

sub process_smppd {

	my ($this) = @_;

	while (1) {

		my ( $sel_r, $sel_w, $sel_x ) = IO::Select->select( $this->selector, undef, undef, 0.5 );

		if ( $sel_r and @$sel_r ) {

			foreach my $reader ( @{$sel_r} ) {

				if ( $reader eq $this->listener ) {

					# New incoming connection
					$this->accept_connect();

				} elsif ( $reader eq $this->link_smppd ) {

					$this->process_from_qproc();
				} else {

					# Find corresponding TCP socket
					my ($esme) = grep { $_->{conn} eq $reader } values %$ESME;

					# Process SMPP traffic from client (ESME)
					$this->process_client($esme);

				}

			} ## end foreach my $reader ( @{$sel_r...})

		} ## end if ( $sel_r and @$sel_r)

	} ## end while (1)

} ## end sub process_smppd

sub process_from_qproc {

	my ($this) = @_;

	warn "Data from Qproc\n";
	my $str = $this->link_smppd->getline();
	print "D: $str";

}

sub accept_connect {

	my ($this) = @_;

	if ( my $conn = $this->listener->accept() ) {

		$this->selector->add($conn);

		my $conn_id = $conn->peerhost . ':' . $conn->peerport;

		$ESME->{$conn_id} = {
			id               => $conn_id,    # connection ID (host:port)
			conn             => $conn,       # TCP socket
			auth             => 0,
			system_id        => undef,
			customer_id      => undef,
			system_type      => undef,
			role             => undef,       # ROLE_RECEIVER, ROLE_TRANSMITTER, ROLE_TRANSCEIVER
			protocol_version => undef,       # V33, V34
			connected        => time(),
		};

	} else {
		warn "Can't accept()\n";
	}

} ## end sub accept_connect

sub process_client {

	my ( $this, $esme ) = @_;

	warn "Data received on SMPP socket\n";

	# Try to read PDU from TCP socket
	if ( my $pdu = $esme->{conn}->read_pdu() ) {

		unless ( defined CMD_TAB->{ $pdu->{cmd} } ) {

			# Unknown command ID
			return;

		}

		my $cmd = CMD_TAB->{ $pdu->{cmd} };

		if ( $esme->{auth} ) {

			if ( $cmd eq 'enquire_link' ) {

				$this->cmd_enquire_link( $esme, $pdu );    # send enquire_link_resp

			} elsif ( $cmd eq 'submit_sm' ) {

				$this->cmd_submit_sm( $esme, $pdu );

			} elsif ( $cmd eq 'unbind' ) {

				# Send unbind_resp and disconnect
				$this->cmd_unbind( $esme, $pdu );
				$this->disconnect_esme($esme);

			} else {
				# proc_wrong($pdu);
			}

		} else {

			# Unauthenticated
			if ( $cmd =~ /bind_(transceiver|transmitter|receiver)/ ) {

				$this->cmd_bind( $esme, $pdu );

			} else {

				# Known command but not allowed in this state
				$this->resp_error( $esme, $pdu, STATUS_TAB->{ESME_RINVBNDSTS} );
				$this->disconnect_esme($esme);

			}

		}

	} elsif ( $esme->{conn}->eof() ) {

		# Process disconnection of ESME
		$this->disconnect_esme($esme);
		return;

	}

} ## end sub process_client

sub disconnect_esme {

	my ( $this, $esme ) = @_;

	$this->selector->remove( $esme->{conn} );    # remove socket from select()
	$esme->{conn}->close();                      # close socket()
	delete( $ESME->{ $esme->{id} } );            # remove ESME from handlers list

	$this->shm_write( $this->get_recv_customers() );

}

sub cmd_submit_sm {

	my ( $this, $esme, $pdu ) = @_;

	warn Dumper($pdu);

	# Do not allow submit_sm for receiver ESME
	if ( $esme->{role} eq ROLE_RECEIVER ) {

		$this->trace("Retrieved submit_sm in receiver mode1");

		$esme->{conn}->submit_sm_resp(
			seq        => $pdu->{seq},
			status     => STATUS_TAB->{ESME_RSUBMITFAIL},
			message_id => '',
		);

		return;
	}

	# TODO - check throttling

	# Get source/destination address information
	my $src_addr     = $pdu->{source_addr};
	my $src_addr_ton = $pdu->{source_addr_ton};
	my $src_addr_npi = $pdu->{source_addr_npi};

	my $dst_addr     = $pdu->{destination_addr};
	my $dst_addr_ton = $pdu->{dest_addr_ton};
	my $dst_addr_npi = $pdu->{dest_addr_npi};

	# **************************************************************************
	# Process data_coding (see ETSI GSM 03.38 specification)
	#
	# Determine: message_class, coding, MWI flags
	my $data_coding = $pdu->{data_coding};

	# Determine message_class
	my $mclass = undef;
	if ( ( $data_coding & 0b00010000 ) eq 0b00010000 ) {
		$mclass = $data_coding & 0b00000011;
	}

	# Determine coding
	# Part.1: is this Latin1 (5.2.19 in SMPP v.3.4. spec. 0b00000011)
	my $coding = 0;
	if ( ( $data_coding & 0b00000011 ) eq 0b00000011 ) {
		$coding = 3;    # Latin1 we are save in Database as 0b0011 ;)
	} else {
		$coding = ( $data_coding & 0b00001100 ) >> 2;
	}

	# Determine UDHI state
	my $udhi      = 0;                    # No UDH by default
	my $esm_class = $pdu->{esm_class};    # see 5.2.12 part of SMPP 3.4 spec
	if ( ( $esm_class & 0b01000000 ) eq 0b01000000 ) {
		$udhi = 1;
	}

	# **************************************************************************
	# Process SM body (UD and UDH)
	my $msg_text = $pdu->{short_message};

	# If have UDH, get if from message
	my $udh = undef;
	if ($udhi) {
		use bytes;
		my ($udhl) = unpack( "C*", bytes::substr( $msg_text, 0, 1 ) );
		$udh = bytes::substr( $msg_text, 0, $udhl + 1 );
		$msg_text = bytes::substr( $msg_text, $udhl + 1 );
		no bytes;
		$udh = str_to_hex($udh);
	}

	# Prepare body
	# For text use UTF-8, for binary - hexdump
	my $body = '';
	if ( $coding eq 0 ) { $body = str_recode( $msg_text, 'GSM0338', 'UTF-8' ); }
	if ( $coding eq 2 ) { $body = str_recode( $msg_text, 'UCS-2BE', 'UTF-8' ); }

	if ( $coding eq 1 ) { $body = str_to_hex($msg_text); }

	my $res = $this->cme->msg_insert(
		dir         => 'MT',
		customer_id => $esme->{customer_id},
		src_app_id  => $this->cme->get_app_id('app_smppd'),
		dst_app_id  => $this->cme->get_app_id('app_hlr'),
		src_addr    => $src_addr,
		dst_addr    => $dst_addr,
		udh         => $udh,
		body        => $body,
		coding      => $coding,
		mclass      => $mclass,
		reg_dlr     => $pdu->{registered_delivery},
		prio        => $pdu->{priority_flag},
		#orig_pdu    => to_json(bless $pdu, 'HASH'),
	);

	if ($res) {

		$esme->{conn}->submit_sm_resp(
			seq        => $pdu->{seq},
			status     => STATUS_TAB->{ESME_ROK},
			message_id => $res->{id},
		);

	} else {

		$esme->{conn}->submit_sm_resp(
			seq        => $pdu->{seq},
			status     => STATUS_TAB->{ESME_RSUBMITFAIL},
			message_id => $res->{id},
		);

	}

} ## end sub cmd_submit_sm

sub cmd_unbind {

	my ( $this, $esme, $pdu ) = @_;

	$esme->{conn}->unbind_resp(
		seq    => $pdu->{seq},
		status => STATUS_TAB->{ESME_ROK},
	);

}

sub cmd_enquire_link {

	my ( $this, $esme, $pdu ) = @_;

	$esme->{conn}->enquire_link_resp(
		seq    => $pdu->{seq},
		status => STATUS_TAB->{ESME_ROK},
	);

}

sub cmd_bind {

	my ( $this, $esme, $pdu ) = @_;

	my $cmd = CMD_TAB->{ $pdu->{cmd} };    # SMPP commend name (bind_transceiver, bind_transmitter, bind_receiver)

	my $remote_ip   = $esme->{conn}->peerhost;
	my $system_id   = $pdu->{system_id};
	my $password    = $pdu->{password};
	my $system_type = $pdu->{system_type};

	#debug( "Auth request [%s]: ip=%s, system_id=%s, password=%s, system_type=%s", $cmd, $remote_ip, $system_id, $password, $system_type );

	my $resp_status = STATUS_TAB->{ESME_RINVPASWD};

	# Try to authenticate ESME using system-id and password
	if ( my $customer = $this->cme->auth_esme( $system_id, $password, $remote_ip ) ) {

		$resp_status                          = STATUS_TAB->{ESME_ROK};
		$ESME->{ $esme->{id} }->{auth}        = 1;                        # Authenticated
		$ESME->{ $esme->{id} }->{system_id}   = $system_id;               # system ID (login)
		$ESME->{ $esme->{id} }->{customer_id} = $customer->{id};          # customer ID

	}

	# Send response with appropriate status
	if ( $cmd eq 'bind_transceiver' ) {
		$esme->{conn}->bind_transceiver_resp( seq => $pdu->{seq}, status => $resp_status, );
		$ESME->{ $esme->{id} }->{role} = ROLE_TRANSCEIVER;
	}
	if ( $cmd eq 'bind_transmitter' ) {
		$esme->{conn}->bind_transmitter_resp( seq => $pdu->{seq}, status => $resp_status, );
		$ESME->{ $esme->{id} }->{role} = ROLE_TRANSMITTER;
	}
	if ( $cmd eq 'bind_receiver' ) {
		$esme->{conn}->bind_receiver_resp( seq => $pdu->{seq}, status => $resp_status, );
		$ESME->{ $esme->{id} }->{role} = ROLE_RECEIVER;
	}

	# Disconnect if unsuccessful authentication
	unless ( $esme->{auth} ) {
		$this->disconnect_esme($esme);
	}

	$this->shm_write( $this->get_recv_customers() );

} ## end sub cmd_bind

sub get_recv_customers {

	my ($this) = @_;

	my $data = {};

	foreach my $esme ( values %$ESME ) {
		next unless ( $esme->{auth} );
		if ( ( $esme->{role} eq ROLE_TRANSCEIVER ) or ( $esme->{role} eq ROLE_RECEIVER ) ) {
			$data->{ $esme->{customer_id} } = 1;
		}
	}

	return $data;
}

sub shm_write {

	my ( $this, $data ) = @_;

	$this->shm->lock(LOCK_EX);
	$this->shm->store( encode_json($data) );
	$this->shm->unlock();

}

sub shm_read {

	my ($this) = @_;

	$this->shm->lock(LOCK_EX);
	my $data = decode_json( $this->shm->fetch );
	$this->shm->unlock;

	return $data;
}

sub resp_error {

	my ( $this, $esme, $pdu, $status ) = @_;

	my $cmd = CMD_TAB->{ $pdu->{cmd} };

	# Send submit_sm_resp
	if ( $cmd eq 'submit_sm' ) {

		$esme->{conn}->submit_sm_resp(
			seq    => $pdu->{seq},
			status => $status,
		);

	} elsif ( $cmd eq 'deliver_sm' ) {

		$esme->{conn}->deliver_sm_resp(
			seq    => $pdu->{seq},
			status => $status,
		);

	} elsif ( $cmd eq 'enquire_link' ) {

		$esme->{conn}->enquire_link_resp(
			seq    => $pdu->{seq},
			status => $status,
		);

	}

} ## end sub resp_error

# ****************************************************************
# Initialization subroutines

sub start_hook {

	my ($this) = @_;

	# Prepare SIGCHLD handler
	$SIG{CHLD} = sub {
		$this->log( 'warning', 'SIGCHLD retrieved' );
		my $waited_pid = wait();
	};

	$this->create_shm();

	# Prepare pair of connected sockets
	my ( $link_smppd, $link_qproc ) = IO::Socket->socketpair( AF_UNIX, SOCK_STREAM, PF_UNSPEC );
	my $qproc_pid = fork();

	if ($qproc_pid) {

		$0 = 'smppd-main';
		$this->role('smppd');
		close($link_qproc);
		$this->link_smppd($link_smppd);
		$this->init_socket();
		$this->selector->add( $this->link_smppd() );

		$SIG{TERM} = sub {
			$this->log( 'warning', 'SIGTERM retrieved' );
			$this->shm(undef);
			exit;
		};

		$SIG{INT} = sub {
			$this->log( 'warning', 'SIGINT retrieved' );
			$this->shm(undef);
			exit;
		};

	} else {

		$0 = 'smppd-qproc';
		$this->role('qproc');
		close($link_smppd);
		$this->link_qproc($link_qproc);
		$this->log( 'info', 'Started queue processor with PID %s', $$ );

	}

	$this->dbh( Colibri::DBI->get_dbh( %{ $this->conf->{db} } ) );
	$this->cme( Colibri::CME->new( dbh => $this->dbh ) );

} ## end sub start_hook

sub create_shm {

	my ($this) = @_;

	my $shm_key = 1920;

	my $shm = undef;

	while ( !$shm ) {
		eval { $shm = IPC::ShareLite->new( -key => $shm_key, -create => 'yes', -destroy => 'yes', -exclusive => 'yes', ); };
		if ($@) { $shm_key++; }
	}

	$this->trace( 'Created SHM segment with key %s', $shm_key );

	$this->shm($shm);
	$this->shm_write( {} );

	return $shm_key;

} ## end sub create_shm

sub init_socket {

	my ($this) = @_;

	if ( $this->conf->{smpp_listen_addr} ) { $this->{smpp_listen_addr} = $this->conf->{smpp_listen_addr}; }
	if ( $this->conf->{smpp_listen_port} ) { $this->{smpp_listen_port} = $this->conf->{smpp_listen_port}; }

	$this->listener(
		Net::SMPP->new_listen(
			$this->{smpp_listen_addr},
			port              => $this->{smpp_listen_port},
			interface_version => 0x00,
			smpp_version      => 0x34,
			addr_ton          => 0x00,
			addr_npi          => 0x01,
			source_addr_ton   => 0x00,
			source_addr_npi   => 0x01,
			dest_addr_ton     => 0x00,
			dest_addr_npi     => 0x01,
			ReuseAddr         => 1,
			ReusePort         => 1,
		)
	);

	unless ( $this->listener ) {
		die( sprintf( "Cannot open listen socket on %s:%s\n%s", $this->{smpp_listen_addr}, $this->{smpp_listen_port}, $@ ) );
	}

	#debug( "Opened listening socket on %s:%s\n", $this->conf->{listen_addr}, $this->conf->{listen_port} );

	# Add listening socket to select()
	$this->selector( IO::Select->new( $this->listener ) );

} ## end sub init_socket

