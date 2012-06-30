package Colibri::Base;

use 5.8.0;
use strict;
use warnings;
use diagnostics -traceonly;

use version; our $VERSION = version->declare('v0.1.0');

use Colibri::Exceptions;

use base 'Class::Accessor::Class';

# Base class properties - common for all successors
__PACKAGE__->mk_class_accessors(
	'debug',     # Debug mode
	'app',       # Application object
	'logger',    # System logger
	'conf',      # Configuration (hash reference)
);

sub new {

	my ( $proto, %params ) = @_;

	my $this = {%params};
	my $class = ref($proto) || $proto;
	bless $this, $class;

	return $this;

}

sub log {

	my ( $this, $level, $msg ) = @_;

	# Logger expected to provide "log()" method
	if ( $this->logger() and $this->logger()->can('log') ) {
		$this->logger->log( $level, $msg );
	} else {
		warn "LOG: [$level] $msg\n";
	}

}

sub trace {

	my ( $this, $msg ) = @_;

	if ( $this->debug ) {
		warn "$msg\n";
	}

}

1;

__END__

=head1 NAME

Colibri::Classs

=cut
