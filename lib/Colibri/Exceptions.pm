package Colibri::Exceptions;

use 5.8.0;
use strict;
use warnings;

use version; our $VERSION = version->declare('v0.1.0');

use Exception::Class (

	'Err::Generic' => {
		'description' => 'Generic exception',
	},

	'Err::Type' => {
		'isa'         => 'Err::Generic',
		'description' => 'Invalid data type',
	},

	'Err::Argument' => {
		'isa'         => 'Err::Generic',
		'description' => 'Invalid arguments in function',
	},

	'Err::File' => {
		'isa'         => 'Err::Generic',
		'description' => 'File operation error',
	},

	'Err::Network' => {
		'isa'         => 'Err::Generic',
		'description' => 'Network operation error',
	},

	# DBMS related
	'Err::DBI' => {
		'isa'         => 'Err::Generic',
		'description' => 'General DBMS operation error',
		'fields'      => ['dberr'],
	},
	'Err::DBI::Connect' => {
		'isa'         => 'Err::DBI',
		'description' => 'DBMS connection error',
	},
	'Err::DBI::SQL' => {
		'isa'         => 'Err::DBI',
		'description' => 'SQL statement error',
	},

	# Application errors
	'Err::Conf' => {
		'isa'         => 'Err::Generic',
		'description' => 'Configuration file error',
	},

	'Err::Logic' => {
		'isa'         => 'Err::Generic',
		'description' => 'Critical business logic error',
	},

);

1;

__END__

=head1 NAME

NetSDS::

=head1 SYNOPSIS

	use NetSDS::;

=head1 DESCRIPTION

C<NetSDS> module contains superclass all other classes should be inherited from.

=cut

=back

=head1 EXAMPLES


=head1 BUGS

Unknown yet

=head1 SEE ALSO

None

=head1 TODO

None

=head1 AUTHOR

Michael Bochkaryov <misha@rattler.kiev.ua>

=head1 LICENSE

GPL

=cut


