package Colibri::Conf;

use 5.8.0;
use strict;
use warnings;

use Colibri::Exceptions;

use Config::General;

use version; our $VERSION = version->declare('v0.1.0');

sub getconf {

	my ( $proto, $path ) = @_;

	# Check if configuration file name is set.
	unless ($path) {
		Err::Conf->throw( message => 'Configuration file name not set.' );
	}

	# Check if configuration file exists and is available for reading
	unless ( ( -f $path ) or ( -r $path ) ) {
		Err::Conf->throw( message => 'Configuration file not exists or is not readable: ' . $path );
	}

	# Read configuration file
	my $conf = Config::General->new(
		-ConfigFile        => $path,
		-AllowMultiOptions => 'yes',
		-UseApacheInclude  => 'yes',
		-InterPolateVars   => 'yes',
		-IncludeRelative   => 'yes',
		-IncludeGlob       => 'yes',
		-UTF8              => 'yes',
	);

	unless ( ref $conf ) {
		Err::Conf->throw( message => 'Configuration file parsing error' );
	}

	# Fetch parsed configuration
	my %cf_hash = $conf->getall or ();

	return {%cf_hash};

} ## end sub getconf

1;

