#!/usr/bin/env perl 

use 5.8.0;
use strict;
use warnings;
use diagnostics -traceonly;

use mro 'c3';

use FindBin;
use lib "$FindBin::Bin/../lib";

use Getopt::Long qw(:config auto_version auto_help pass_through);
use Config::General;
use DBI;
use IO::Select;
use IO::Socket::INET;
use Net::SMPP;
use Time::HiRes qw(sleep time);

use Colibri::Utils;
use Colibri::CME;

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

my $DEBUG;                       # Send debug output to STDOUT
my $DAEMON;                      # Run as daemon
my $CONF_FILE;                   # Path to configuration file
my $CONF = {};                   # Configuration
my $LISTENER;
my $SELECTOR;
my $DBH;
my $ESME = {};                   # ESME descriptors hash reference

initialize();
main_loop();
finalize();

1;

# ****************************************************************
# Processing subroutines

sub main_loop {

	while (1) {
		# Wait for incoming events on SMPP sockets
		my ( $sel_r, $sel_w, $sel_x ) = IO::Select->select( $SELECTOR, undef, undef, 0.0005 );

		if ( $sel_r and @$sel_r ) {
			foreach my $reader ( @{$sel_r} ) {

				if ( $reader eq $LISTENER ) {

					# New incoming connection
					warn "Connect!\n";
					_accept_connect();

				} else {

					# Find corresponding TCP socket
					my ($esme) = grep { $_->{conn} eq $reader } values %$ESME;

					# Process SMPP traffic from client (ESME)
					_process_client($esme);

				}

			}

		} ## end if ( $sel_r and @$sel_r)
	} ## end while (1)

} ## end sub main_loop

sub _accept_connect {

	if ( my $conn = $LISTENER->accept() ) {

		$SELECTOR->add($conn);

		my $conn_id = $conn->peerhost . ':' . $conn->peerport;

		$ESME->{$conn_id} = {
			id               => $conn_id,    # connection ID (host:port)
			conn             => $conn,       # TCP socket
			auth             => 0,
			system_id        => undef,
			system_type      => undef,
			role             => undef,       # ROLE_RECEIVER, ROLE_TRANSMITTER, ROLE_TRANSCEIVER
			protocol_version => undef,       # V33, V34
			connected        => time(),
		};

	} else {
		warn "Can't accept()\n";
	}

} ## end sub _accept_connect

sub _process_client {

	my $esme = shift;

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

				cmd_enquire_link( $esme, $pdu );    # send enquire_link_resp

			} elsif ( $cmd eq 'submit_sm' ) {

				cmd_submit_sm( $esme, $pdu );

			} elsif ( $cmd eq 'unbind' ) {

				# Send unbind_resp and disconnect
				cmd_unbind( $esme, $pdu );
				_disconnect_esme($esme);

			} else {
				# proc_wrong($pdu);
			}

		} else {

			# Unauthenticated
			if ( $cmd =~ /bind_(transceiver|transmitter|receiver)/ ) {

				cmd_bind( $esme, $pdu );

			} else {

				# Known command but not allowed in this state
				_resp_error( $esme, $pdu, STATUS_TAB->{ESME_RINVBNDSTS} );
				_disconnect_esme($esme);

			}

		}

	} elsif ( $esme->{conn}->eof() ) {

		# Process disconnection of ESME
		_disconnect_esme($esme);
		return;

	}

} ## end sub _process_client

sub _disconnect_esme {

	my ($esme) = @_;

	$SELECTOR->remove( $esme->{conn} );    # remove socket from select()
	$esme->{conn}->close();                # close socket()
	delete( $ESME->{ $esme->{id} } );      # remove ESME from handlers list

}

sub cmd_submit_sm {

	my ( $esme, $pdu ) = @_;

	warn Dumper($pdu);

	# Do not allow submit_sm for receiver ESME
	if ( $esme->{role} eq ROLE_RECEIVER ) {
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
		$udh = conv_str_hex($udh);
	}


} ## end sub cmd_submit_sm

sub cmd_unbind {

	my ( $esme, $pdu ) = @_;

	$esme->{conn}->unbind_resp(
		seq    => $pdu->{seq},
		status => STATUS_TAB->{RINV_OK},
	);

}

sub cmd_enquire_link {

	my ( $esme, $pdu ) = @_;

	$esme->{conn}->enquire_link_resp(
		seq    => $pdu->{seq},
		status => STATUS_TAB->{RINV_OK},
	);

}

sub cmd_bind {

	my ( $esme, $pdu ) = @_;

	my $cmd = CMD_TAB->{ $pdu->{cmd} };    # SMPP commend name (bind_transceiver, bind_transmitter, bind_receiver)

	my $remote_ip   = $esme->{conn}->peerhost;
	my $system_id   = $pdu->{system_id};
	my $password    = $pdu->{password};
	my $system_type = $pdu->{system_type};

	debug( "Auth request [%s]: ip=%s, system_id=%s, password=%s, system_type=%s", $cmd, $remote_ip, $system_id, $password, $system_type );

	my $resp_status = STATUS_TAB->{ESME_RINVPASWD};

	# Try to authenticate ESME using system-id and password
	if ( _auth_esme( $remote_ip, $system_id, $password ) ) {

		$resp_status                        = STATUS_TAB->{RINV_OK};
		$ESME->{ $esme->{id} }->{auth}      = 1;                       # Authenticated
		$ESME->{ $esme->{id} }->{system_id} = $system_id;              # system ID (login)

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
		_disconnect_esme($esme);
	}

} ## end sub cmd_bind

sub _auth_esme {

	my ( $remote_ip, $system_id, $password ) = @_;

	my $res = $DBH->selectrow_hashref( "select * from stream.customers where login=? and password=? and active limit 1", undef, $system_id, $password );
	if ($res) {
		warn Dumper($res);
	} else {
		return undef;
	}

	return 1;
}

sub _resp_error {

	my ( $esme, $pdu, $status ) = @_;

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

} ## end sub _resp_error

# ****************************************************************
# Initialization subroutines

sub initialize {

	_init_defaults();
	_init_cli();
	_init_config();
	#_init_sig_handlers();
	_init_dbi();
	_init_socket();

}

sub _init_defaults {

	$DEBUG = 1;

	$CONF_FILE = './smppserver.conf';    # local configuration

	$CONF->{listen_addr} = '0.0.0.0';    # all interfaces
	$CONF->{listen_port} = 2775;         # defult SMPP port by IANA

}

sub _init_cli {

	# Get command line arguments
	GetOptions(
		'conf=s'  => \$CONF_FILE,
		'debug!'  => \$DEBUG,
		'daemon!' => \$DAEMON,
	);

}

sub _init_config {
}

sub _init_sig_handlers {

	$| = 1;

	$SIG{HUP} = sub {
		warn "HUP!\n";
	};

	$SIG{TERM} = sub {
		warn "TERM!\n";
	};

	$SIG{INT} = sub {
		warn "INT !\n";
	};

	$SIG{PIPE} = sub {
		warn "PIPE !\n";
	};

} ## end sub _init_sig_handlers

sub _init_dbi {

	$DBH = DBI->connect( 'dbi:Pg:dbname=stream;host=192.168.1.53', 'misha', '' ) or die "Cannot connect to DBMS";
}

sub _init_socket {

	$LISTENER = Net::SMPP->new_listen(
		$CONF->{listen_addr},
		port              => $CONF->{listen_port},
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
	);

	unless ($LISTENER) {
		die( sprintf( "Cannot open listen socket on %s:%s\n%s", $CONF->{listen_addr}, $CONF->{listen_port}, $@ ) );
	}

	debug( "Opened listening socket on %s:%s\n", $CONF->{listen_addr}, $CONF->{listen_port} );

	# Add listening socket to select()
	$SELECTOR = IO::Select->new($LISTENER);

} ## end sub _init_socket

# ****************************************************************
# Finalization subroutines

sub finalize {

}

# ****************************************************************
# Supplementary subroutines

sub debug {

	my ( $msg, @params ) = @_;
	if ($DEBUG) { printf( "$msg\n", @params ); }

}

