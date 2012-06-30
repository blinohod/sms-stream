package Colibri::Logger;

use 5.8.0;
use warnings;

use Unix::Syslog qw(:macros :subs);

use version; our $VERSION = version->declare('v0.1.0');

# Set logging facility
my %facility_map = (
	'local0' => LOG_LOCAL0,
	'local1' => LOG_LOCAL1,
	'local2' => LOG_LOCAL2,
	'local3' => LOG_LOCAL3,
	'local4' => LOG_LOCAL4,
	'local5' => LOG_LOCAL5,
	'local6' => LOG_LOCAL6,
	'local7' => LOG_LOCAL7,
	'user'   => LOG_USER,
	'daemon' => LOG_DAEMON,
);

# Level aliases
my %LEVELS = (
	alert     => LOG_ALERT,
	crit      => LOG_CRIT,
	critical  => LOG_CRIT,
	deb       => LOG_DEBUG,
	debug     => LOG_DEBUG,
	emerg     => LOG_EMERG,
	emergency => LOG_EMERG,
	panic     => LOG_EMERG,
	err       => LOG_ERR,
	error     => LOG_ERR,
	inf       => LOG_INFO,
	info      => LOG_INFO,
	inform    => LOG_INFO,
	note      => LOG_NOTICE,
	notice    => LOG_NOTICE,
	warning   => LOG_WARNING,
	warn      => LOG_WARNING,
);

sub new {

	my ( $class, %params ) = @_;

	my $self = {};

	# Set application identification name
	my $name = $params{name} || 'colibri';

	my $mask = $params{mask} || 'warning';

	my $LEV = $LEVELS{$mask} || LOG_INFO;
	setlogmask( LOG_UPTO($LEV) );

	my $facility = LOG_LOCAL0;    # default is local0
	if ( $params{facility} ) {
		$facility = $facility_map{ $params{facility} } || LOG_LOCAL0;
	}

	openlog( $name, LOG_PID | LOG_CONS | LOG_NDELAY, $facility );

	return bless $self, $class;

} ## end sub new

sub log {

	my ( $self, $level, $message ) = @_;

	if ( !$message ) {
		return undef;
	}

	my $LEV = $LEVELS{$level} || LOG_INFO;

	syslog( $LEV, $message );

}

sub DESTROY {
	closelog();
}

1;

