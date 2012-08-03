package Colibri::App::GUI;

use 5.8.0;
use strict;
use warnings;

use base 'Colibri::App';

use version; our $VERSION = version->declare('v0.1.0');

use CGI::Fast;
use CGI::Cookie;
use JSON;

sub new {

	my ( $class, %params ) = @_;

	my $this = $class->SUPER::new(
		daemon   => undef,    # daemonize if 1
		pid_file => undef,    # check PID file if 1
		%params,
	);

	return $this;

}

__PACKAGE__->mk_accessors('cgi');
__PACKAGE__->mk_accessors('dbh');

sub process {

	my ($this) = @_;

	while ( my $req = CGI::Fast->new() ) {

		$this->cgi($req);

		my $action = 'default';
		my $format = 'html';

		# Parse PATH_INFO to determine action and output format
		if ( $this->cgi->path_info() =~ /^\/(\w[\w\d\_]*)\.([\w\d]+)$/ ) {
			( $action, $format ) = ( $1, $2 );
		}

		# Find action
		my $action_sub = 'action_' . $action;
		unless ( $this->can($action_sub) ) {
			print $this->cgi->header( -status => '404 Document not found', -type => 'text/html', );
			print "<h1>Wrong action called!</h1>";
			next;
		}

		my $res = $this->$action_sub();

		if ( defined $res ) {

			# Scalar HTML
			unless ( ref($res) ) {
				print $this->cgi->header( -status => '200 OK', -type => 'text/html', -charset => 'utf-8' );
				print $res;
			}

			# Determine what to do with return
			if ( ref($res) eq 'HASH' ) {
				print $this->cgi->header( -status => '200 OK', -type => 'application/json', -charset => 'utf-8', );
				print encode_json($res);
			}

		}

	} ## end while ( my $req = CGI::Fast...)

} ## end sub process

sub action_default {

	my ($this) = @_;

	$this->trace('Default GUI action');
	print $this->cgi->header( -type => 'text/plain', -status => '500 Internal Error', );
	print "Default action is not redefined!\n";
	return undef;

}

sub _initialize {

	my ($this) = @_;

	$this->SUPER::_initialize();

	$CGI::Fast::Ext_Request = FCGI::Request( \*STDIN, \*STDOUT, \*STDERR, \%ENV, 0, FCGI::FAIL_ACCEPT_ON_INTR() );

}

sub _set_req_cookies {

	my ($this) = @_;

	my %cookies = CGI::Cookie->fetch();
	$this->{_req_cookies} = \%cookies;
	return 1;

}

1;

