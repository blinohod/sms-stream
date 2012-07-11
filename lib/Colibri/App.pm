package Colibri::App;

use 5.8.0;
use strict;
use warnings;

use base 'Colibri::Base';

use version; our $VERSION = version->declare('v0.1.0');

use Colibri::Logger;    # API to syslog daemon
use Colibri::Conf;      # Configuration file processor
use Colibri::Utils;     # Supplementary routines

use Getopt::Long qw(:config auto_version auto_help pass_through);

use POSIX;

sub run_app {

	my $class = shift(@_);

	my $app = $class->new(@_) or die 'Cannot start application';

	# Initialization
	$app->_initialize();
	if ( $app->can('start_hook') ) {
		$app->start_hook();
	}

	# Main process
	if ( $app->can('process') ) {
		$app->process();
	} else {
		die 'FATAL: process() method is not defined.';
	}

	# Finalization
	if ( $app->can('stop_hook') ) {
		$app->stop_hook();
	}
	$app->_finalize();

} ## end sub run_app

sub new {

	my ( $class, %params ) = @_;

	my $this = $class->SUPER::new(
		name      => undef,    # application name
		daemon    => undef,    # daemonize if 1
		pid_file  => undef,    # check PID file if 1
		conf_file => undef,    # configuration file name
		%params,
	);

	return $this;

}

__PACKAGE__->mk_accessors('name');        # Application name (for logs and diagnostics)
__PACKAGE__->mk_accessors('pid_file');    # PID file path
__PACKAGE__->mk_accessors('conf_file');
__PACKAGE__->mk_accessors('daemon');

sub _initialize {

	my ( $this, %params ) = @_;

	$this->_determine_name();             # determine application name from process name
	$this->_get_cli_params();             # process standard CLI parameters

	# Daemonize, if needed
	if ( $this->daemon() ) {
		$this->_daemonize();
	}

	# Create syslog handler
	if ( !$this->logger ) {
		my $log_mask = $this->debug ? 'debug' : 'info';
		$this->logger( Colibri::Logger->new( name => $this->{name}, mask => $log_mask ) );
		$this->log( "debug", "Logger started" );
	}

	# Process PID file if necessary
	if ( $this->pid_file() ) {
		$this->_set_pid_file();
	}

	# Initialize configuration
	if ( $this->conf_file ) {

		# Get configuration file
		if ( my $conf = Colibri::Conf->getconf( $this->conf_file ) ) {
			$this->conf($conf);
			$this->log( "info", "Configuration file read OK: " . $this->conf_file );
		} else {
			$this->log( "error", "Cannot read configuration file: " . $this->conf_file );
		}

	}

} ## end sub _initialize

sub _daemonize {

	my ($this) = @_;

	my $pid = fork();

	if ($pid) { exit(0); }

	# Close standard I/O handles
	close STDIN;
	close STDOUT;
	close STDERR;

	chdir '/';              # Change work dir to root
	POSIX::setsid();        # Detach from control TTY
	$this->debug(undef);    # No debug in daemon mode

}

sub _set_pid_file {

	my ($this) = @_;

	my $pid = $$;
	my $pf  = $this->pid_file();

	# Check for existing PID file
	if ( -f $pf ) {
		$this->log( 'error', "PID file already exists: $pf" );

		# Check if it's possible read and write PID file
		unless ( ( -r $pf ) or ( -w $pf ) ) {
			$this->log( 'fatal', "Wrong permissions on PID file: $pf" );
			die "Wrong permissions on PID file: $pf";
		}

		my $check_pid = file_read($pf);

		# Check if PID file contains PID and process exists
		if ( $check_pid =~ /^(\d+)$/ ) {
			if ( -e "/proc/$1/cmdline" ) {
				$this->log( 'fatal', 'Process exists with PID file!' );
				die "Wrong permissions on PID file: $pf";
			}
		}

		# Remove wrong PID file
		$this->log( 'error', 'Wrong PID file contents, removing!' );
		unlink $pf;

	} ## end if ( -f $pf )

	# Write PID file
	unless ( file_write( $pf, "$pid" ) ) {
		$this->log( 'error', "Cannot write PID file: $pf" );
		die "Cannot write PID file: $pf";
	}

} ## end sub _set_pid_file

sub _finalize {
	my ( $this, $msg ) = @_;

	# Remove PID file
	if ( $this->pid_file ) {
		$this->log( 'debug', 'Remove PID file: ' );
		unlink $this->pid_file;
	}

	$this->log( 'debug', 'Application stopped' );
}

# Determine application name from script name
sub _determine_name {

	my ($this) = @_;

	# Dont override predefined name
	unless ( $this->{name} ) {
		$this->{name} = $0;    # executable script
		$this->{name} =~ s/^.*\///;               # remove directory path
		$this->{name} =~ s/\.(pl|cgi|fcgi)$//;    # remove standard extensions
	}

}

# Determine execution parameters from CLI
sub _get_cli_params {

	my ($this) = @_;

	my $conf   = undef;
	my $debug  = undef;
	my $daemon = undef;

	# Get command line arguments
	GetOptions(
		'conf=s'  => \$conf,
		'debug!'  => \$debug,
		'daemon!' => \$daemon,
	);

	# Set configuration file name
	if ( defined $conf ) {
		$this->conf_file($conf);
		$this->trace("CLI: config[$conf]");
	}

	# Set debug mode
	if ( defined $debug ) {
		$this->debug(1);
		$this->trace("CLI: debug mode on");
	}

	# Set daemon mode
	if ( defined $daemon ) {
		$this->daemon(1);
		$this->trace("CLI: daemon mode on");
	}

} ## end sub _get_cli_params

1;

