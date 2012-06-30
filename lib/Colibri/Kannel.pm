package Colibri::Kannel;

use 5.8.0;
use strict;
use warnings;

use Colibri::Utils;
use LWP::UserAgent;
use URI::Escape;
use XML::LibXML;

use base qw(
  Colibri::Base
  Exporter
);

use version; our $VERSION = version->declare('v0.1.0');

use constant USER_AGENT => 'Colibri/0.1.0 VASP';

our @EXPORT = qw(
  STATE_DELIVERED
  STATE_UNDELIVERABLE
  STATE_ENROUTE
  STATE_ACCEPTED
  STATE_REJECTED

  ESME_RINVMSGLEN
  ESME_RINVCMDID
  ESME_RINVBNDSTS
  ESME_RSYSERR
  ESME_RINVDSTADR
  ESME_RMSGQFUL
  ESME_RTHROTTLED
  ESME_RUNKNOWNERR
  ESME_RTIMEOUT
  ESME_LICENSE
  ESME_CHARGING
);

# SMS delivery states
use constant STATE_DELIVERED     => 1;     # Delivered to MS
use constant STATE_UNDELIVERABLE => 2;     # Undeliverable
use constant STATE_ENROUTE       => 4;     # Queued on SMSC
use constant STATE_ACCEPTED      => 8;     # Received by SMSC
use constant STATE_REJECTED      => 16;    # Rejected by SMSC

# Reject codes from SMSC
use constant ESME_RINVMSGLEN  => 1;        # Wrong length
use constant ESME_RINVCMDID   => 3;        # Wrong SMPP command
use constant ESME_RINVBNDSTS  => 4;
use constant ESME_RSYSERR     => 8;
use constant ESME_RINVDSTADR  => 11;       # Invalid destination address
use constant ESME_RMSGQFUL    => 20;
use constant ESME_RTHROTTLED  => 88;
use constant ESME_RUNKNOWNERR => 255;
use constant ESME_RTIMEOUT    => 1057;
use constant ESME_LICENSE     => 1058;     # License restriction (vendor specific)
use constant ESME_CHARGING    => 1059;     # Low billing balance (vendor specific)
use constant ESME_CHARGING_PP => 1111;     # Low billing balance on prepaid (vendor specific)

sub new {

	my ( $class, %params ) = @_;

	my $this = $class->SUPER::new(
		admin_url       => 'http://127.0.0.1:13000/',
		admin_passwd    => 'secret',
		sendsms_url     => 'http://127.0.0.1:13013/cgi-bin/sendsms',
		sendsms_user    => 'colibri',
		sendsms_passwd  => 'secret',
		dlr_url         => 'http://127.0.0.1/smsc/kannel_receiver.fcgi',
		default_smsc    => undef,
		default_timeout => 30,                                             # 30 seconds enough for sending timeout
		%params,
	);

	# Initialize LWP user agent
	$this->{_ua} = LWP::UserAgent->new();
	$this->{_ua}->agent( USER_AGENT . "/$VERSION" );

	# Initialize XML parser
	$this->{_xml} = XML::LibXML->new();
	$this->{_xml}->validation(0);
	$this->{_xml}->recover(1);

	__PACKAGE__->mk_accessors('admin_url');
	__PACKAGE__->mk_accessors('admin_passwd');
	__PACKAGE__->mk_accessors('sendsms_url');
	__PACKAGE__->mk_accessors('sendsms_user');
	__PACKAGE__->mk_accessors('sendsms_passwd');
	__PACKAGE__->mk_accessors('dlr_url');
	__PACKAGE__->mk_accessors('default_smsc');
	__PACKAGE__->mk_accessors('default_timeout');

	return $this;

} ## end sub new

sub send {

	my ( $this, %params ) = @_;

	my %send = (
		'username' => $this->sendsms_user,
		'password' => $this->sendsms_passwd,
		'charset'  => 'UTF-8',                 # Local text representation
		'coding'   => 0,                       # 7 bit GSM 03.38
	);

	# Then we override message parameters

	# Set sendsms URL
	my $send_url = $this->sendsms_url;
	if ( $params{sendsms_url} ) {
		$send_url = $params{sendsms_url};
	}

	# Set sendsms username
	if ( $params{sendsms_user} ) {
		$send{username} = $params{sendsms_user};
	}

	# Set sendsms password
	if ( $params{sendsms_passwd} ) {
		$send{password} = $params{sendsms_passwd};
	}

	# Set source address
	if ( $params{from} ) {
		$send{from} = uri_escape( $params{from} );
	}

	# Set destination address
	if ( $params{to} ) {
		$send{to} = uri_escape( $params{to} );
	}

	# Set message text
	if ( defined $params{text} ) {
		$send{text} = uri_escape( $params{text} );
	}

	# Set message UDH
	if ( $params{udh} ) {
		$send{udh} = uri_escape( $params{udh} );
	}

	# Set message charset
	if ( $params{charset} ) {
		$send{charset} = $params{charset};
	}

	# Set message mclass
	if ( defined $params{mclass} ) {
		$send{mclass} = $params{mclass};
	}

	# Set message waiting indicator
	if ( defined $params{mwi} ) {
		$send{mwi} = $params{mwi};
	}

	# Set data coding
	if ( $params{coding} ) {
		$send{coding} = $params{coding};
	}

	# Set message TTL in minutes
	if ( $params{validity} and ( is_int( $params{validity} ) ) ) {
		$send{validity} = $params{validity};
	}

	# Set deferred delivery in minutes
	if ( $params{deferred} and ( is_int( $params{deferred} ) ) ) {
		$send{deferred} = $params{deferred};
	}

	# Set message priority (0 to 3)
	if ( defined $params{priority} and ( is_int( $params{priority} ) and ( $params{priority} <= 3 ) and ( $params{priority} >= 0 ) ) ) {
		$send{priority} = $params{priority};
	}

	# Set SMSC id
	if ( $params{smsc} ) {
		$send{smsc} = $params{smsc};
	}

	# Set DLR fetching mask (see kannel documentation)
	if ( $params{dlr_id} ) {
		$send{'dlr-url'} = $this->make_dlr_url( msgid => $params{dlr_id} );

		# Set DLR fetching mask (see kannel documentation)
		if ( $params{dlr_mask} ) {
			$send{'dlr-mask'} = $params{dlr_mask};
		} else {
			$send{'dlr-mask'} = 3;    # default mask (delivered and undeliverable)
		}
	}

	# Set meta data
	if ( $params{meta} ) {
		$send{'meta-data'} = $this->make_meta( %{ $params{meta} } );
	}

	# Set HTTP request timeout
	my $timeout = $this->default_timeout;
	if ( $params{timeout} ) {
		$timeout = $params{timeout};
	}
	$this->{_ua}->timeout($timeout);

	# Prepare HTTP request
	my @pairs = map $_ . '=' . $send{$_}, keys %send;
	my $req = HTTP::Request->new( GET => $send_url . "?" . join '&', @pairs );

	# Send request
	my $res = $this->{_ua}->request($req);

	# Analyze response
	if ( $res->is_success ) {
		return $res->content;
	} else {
		return $this->error( $res->status_line );
	}

} ## end sub send

sub receive {

	my ( $this, $cgi ) = @_;

	my %ret = ();

	# Set message type (MO or DLR)
	if ( $cgi->param('type') ) {
		if ( $cgi->param('type') eq 'mo' ) {
			%ret = $this->receive_mo($cgi);
		} elsif ( $cgi->param('type') eq 'dlr' ) {
			%ret = $this->receive_dlr($cgi);
		}

		return %ret;

	} else {
		return $this->error("Unknown message type received");
	}

} ## end sub receive

sub receive_mo {

	my ( $this, $cgi ) = @_;

	my %ret = (
		type => 'mo',
	);

	# Set SMSC Id (smsc=%i)
	if ( $cgi->param('smsc') ) {
		$ret{smsc} = $cgi->param('smsc');
	} else {
		$ret{smsc} = undef;
	}

	# Set SMSC message Id (smsid=%I)
	if ( $cgi->param('smsid') ) {
		$ret{smsid} = $cgi->param('smsid');
	} else {
		$ret{smsid} = undef;
	}

	# Set source (subscriber) address (from=%p)
	if ( $cgi->param('from') ) {
		$ret{from} = $cgi->param('from');
	}

	# Set destination (service) address (to=%P)
	if ( $cgi->param('to') ) {
		$ret{to} = $cgi->param('to');
	}

	# Set timestamp information (time=%t)
	if ( $cgi->param('time') ) {
		$ret{time} = $cgi->param('time');
	}

	# Set UNIX timestamp information (unixtime=%T)
	if ( $cgi->param('unixtime') ) {
		$ret{unixtime} = $cgi->param('unixtime');
	}

	# Set message text (text=%a)
	if ( defined $cgi->param('text') ) {
		$ret{text} = $cgi->param('text');
	}

	# Set binary message (bin=%b)
	if ( defined $cgi->param('bin') ) {
		$ret{bin} = $cgi->param('bin');
	}

	# Set UDH (udh=%u)
	if ( $cgi->param('udh') ) {
		$ret{udh} = $cgi->param('udh');
	}

	# Set coding (coding=%c)
	if ( defined $cgi->param('coding') ) {
		$ret{coding} = $cgi->param('coding') + 0;
	}

	# Set charset (charset=%C)
	if ( $cgi->param('charset') ) {
		$ret{charset} = $cgi->param('charset');
	}

	# Set message class (mclass=%m)
	if ( $cgi->param('mclass') ) {
		$ret{mclass} = $cgi->param('mclass');
	}

	# Set billing information (binfo=%B)
	if ( $cgi->param('binfo') ) {
		$ret{binfo} = $cgi->param('binfo');
	}

	# Convert message text to UTF-8
	if ( 1 != $ret{coding} ) {
		# iT's text message
		$ret{text} = str_recode( $ret{text}, $ret{charset} );
		$ret{text} = str_encode( $ret{text} );
	}

	# Process optional SMPP TLV (meta=%D)
	if ( $cgi->param('meta') ) {
		my $meta_str = $cgi->param('meta');
		$ret{meta} = {};
		if ( $meta_str =~ /^\?smpp\?(.*)$/ ) {
			foreach my $tlv_par ( split /\&/, $1 ) {
				my ( $tag, $val ) = split /\=/, $tlv_par;
				$ret{meta}->{$tag} = $val;
			}
		}
	}

	return %ret;

} ## end sub receive_mo

sub receive_dlr {

	my ( $this, $cgi ) = @_;

	my %ret = (
		type => 'dlr',
	);

	# Set SMSC Id (smsc=%i)
	if ( $cgi->param('smsc') ) {
		$ret{smsc} = $cgi->param('smsc');
	} else {
		$ret{smsc} = undef;
	}

	# Set VASP message Id (msgid=our_id)
	if ( $cgi->param('msgid') ) {
		$ret{msgid} = $cgi->param('msgid');
	} else {
		$ret{msgid} = undef;
	}

	# Set SMSC message Id (smsid=%I)
	if ( $cgi->param('smsid') ) {
		$ret{smsid} = $cgi->param('smsid');
	} else {
		$ret{smsid} = undef;
	}

	# Set source (subscriber) address (from=%p)
	if ( $cgi->param('from') ) {
		$ret{from} = $cgi->param('from');
	}

	# Set destination (service) address (to=%P)
	if ( $cgi->param('to') ) {
		$ret{to} = $cgi->param('to');
	}

	# Set timestamp information (time=%t)
	if ( $cgi->param('time') ) {
		$ret{time} = $cgi->param('time');
	}

	# Set UNIX timestamp information (unixtime=%T)
	if ( $cgi->param('unixtime') ) {
		$ret{unixtime} = $cgi->param('unixtime');
	}

	# Set DLR state (dlr=%d)
	$ret{dlr_state} = $cgi->param('dlr');

	# Set DLR message (dlrmsg=%A)
	$ret{dlr_msg} = $cgi->param('dlrmsg');

	# Process return code if not success
	if ( $ret{dlr_msg} =~ /^NACK\/(\d+)\// ) {
		$this->{reject_code} = $1;
	}

	return %ret;

} ## end sub receive_dlr

sub make_dlr_url {

	my ( $this, %params ) = @_;

	# Set reference to MT message Id for identification
	my $msgid = $params{msgid};

	# Set DLR base URL from object property or method parameter
	my $dlr_url = $this->{dlr_url};
	if ( $params{dlr_url} ) { $dlr_url = $params{dlr_url}; }

	$dlr_url .= "?type=dlr&msgid=$msgid&smsid=%F&from=%p&to=%P&time=%t&unixtime=%T&dlr=%d&dlrmsg=%A";

	return conv_str_uri($dlr_url);

}

sub make_meta {

	my ( $this, %params ) = @_;

	my $meta_str = '?smpp?';    # FIXME: only 'smpp' group allowed

	my @pairs = map $_ . '=' . $params{$_}, keys %params;
	$meta_str .= join '&', @pairs;

	return conv_str_uri($meta_str);

}

sub status {

	my ($this) = @_;

	my $res = $this->{_ua}->get( $this->admin_url . "status.xml" );
	if ( $res->is_success ) {

		# Parse XML and retrieve DOM structure
		#
		# NOTE: we use eval{} because of XML::LibXML calls die() on parser errors
		my $doc = undef;
		eval { $doc = $this->{_xml}->parse_string( $res->content )->documentElement(); };

		# Catch exceptions
		if ($@) {
			return $this->error("Can't parse XML from Kannel API");
		}

		# ==========================
		# Preparing result structure

		# Version string
		my $result = {
			version => $doc->findvalue('/gateway/version'),
		};

		# Total Kannel status and uptime
		#
		# Sample XML part from status.xml API
		# <status>suspended, uptime 32d 7h 26m 43s</status>
		if ( $doc->findvalue('/gateway/status') =~ /^(\S+),\s+uptime\s+(.+)$/ ) {
			$result->{status} = $1;
			$result->{uptime} = $2;
		}

		# Common SMS information
		$result->{sms} = {
			received_total  => $doc->findvalue('/gateway/sms/received/total'),
			received_queued => $doc->findvalue('/gateway/sms/received/queued'),
			sent_total      => $doc->findvalue('/gateway/sms/sent/total'),
			sent_queued     => $doc->findvalue('/gateway/sms/sent/queued'),
			storesize       => $doc->findvalue('/gateway/sms/storesize'),
			inbound         => $doc->findvalue('/gateway/sms/inbound'),
			outbound        => $doc->findvalue('/gateway/sms/outbound'),
		};

		# Common DLR information
		$result->{dlr} = {
			queued  => $doc->findvalue('/gateway/dlr/queued'),
			storage => $doc->findvalue('/gateway/dlr/storage'),
		};

		# SMSC connections information
		$result->{'smsc'} = [];

		foreach ( $doc->findnodes('/gateway/smscs/smsc') ) {
			my $smsc = {
				name     => $_->findvalue('name'),
				id       => $_->findvalue('id'),
				status   => $_->findvalue('status'),
				received => $_->findvalue('received'),
				sent     => $_->findvalue('sent'),
				failed   => $_->findvalue('failed'),
				queued   => $_->findvalue('queued'),
			};
			if ( $smsc->{status} =~ /online\s+(.+)/ ) {
				$smsc->{status} = 'online';
				$smsc->{uptime} = $1;
			}

			push @{ $result->{'smsc'} }, $smsc;
		}

		return $result;

	} ## end if ( $res->is_success )

	else {
		return $this->error( "Can't retrieve Kannel status: " . $res->status_line );
	}

} ## end sub status

sub store_status {

	my ($this) = @_;

}

sub shutdown {
	my ($this) = @_;
	return $this->_send_cmd('shutdown');
}

sub suspend {
	my ($this) = @_;
	return $this->_send_cmd('suspend');
}

sub isolate {
	my ($this) = @_;
	return $this->_send_cmd('isolate');
}

sub resume {
	my ($this) = @_;
	return $this->_send_cmd('resume');
}

sub restart {
	my ($this) = @_;
	return $this->_send_cmd('restart');
}

sub flush_dlr {
	my ($this) = @_;
	return $this->_send_cmd('flush-dlr');
}

sub reload_lists {
	my ($this) = @_;
	return $this->_send_cmd('reload-lists');
}

sub log_level {
	my ( $this, $level ) = @_;
	return $this->_send_cmd( 'log-level', level => $level );
}

sub start_smsc {
	my ( $this, $smsc ) = @_;
	return $this->_send_cmd( 'start-smsc', smsc => $smsc );
}

sub stop_smsc {
	my ( $this, $smsc ) = @_;
	return $this->_send_cmd( 'stop-smsc', smsc => $smsc );
}

sub add_smsc {
	my ( $this, $smsc ) = @_;
	return $this->_send_cmd( 'add-smsc', smsc => $smsc );
}

sub remove_smsc {
	my ( $this, $smsc ) = @_;
	return $this->_send_cmd( 'remove-smsc', smsc => $smsc );
}

sub _send_cmd {

	my ( $this, $cmd, %params ) = @_;

	# Prepare base URL with administrative URL and password
	my $url = $this->admin_url . "$cmd?password=" . $this->admin_passwd;

	# Add optional parameters
	foreach ( keys %params ) {
		$url .= "&" . $_ . "=" . $params{$_};
	}

	# Prepare and send HTTP request to Kannel admin API
	my $req = HTTP::Request->new( GET => $url );
	my $res = $this->{_ua}->request($req);

	# Analyze HTTP response
	if ( $res->is_success ) {
		# OK - send result data "as is"
		return $res->content;
	} else {
		# Error - send error string
		return $this->error( $res->status_line );
	}

} ## end sub _send_cmd

1;

