package Colibri::DBI;

use 5.8.0;
use strict;
use warnings;

use DBI;

use Colibri::Exceptions;

use version; our $VERSION = version->declare('v0.1.0');

sub get_dbh {

	my ( $class, %params ) = @_;

	my $dsn = 'dbi:Pg:';

	%params = (
		host   => '',
		port   => '',
		user   => 'stream',
		passwd => 'stream',
		dbname => 'stream',
		%params,
	);

	# Prepare DSN
	$dsn .= 'dbname=' . $params{dbname};
	if ( $params{host} ) { $dsn .= ';host=' . $params{host}; }
	if ( $params{port} ) { $dsn .= ';port=' . $params{port}; }

	# Connect to DBMS
	return _connect( $dsn, $params{user}, $params{passwd} );

} ## end sub get_dbh

sub _connect {

	my ( $dsn, $user, $passwd ) = @_;

	my $attrs = {
		AutoCommit     => 1,    # Commit each statement unless implicit transaction
		PrintError     => 0,    # Errors output is implemented other way
		pg_enable_utf8 => 1,    # Treat text data from DBMS as UTF-8 instead of bytes
	};

	# Try to connect to DBMS
	my $dbh = DBI->connect_cached( $dsn, $user, $passwd, );

	# Exit with exception if cannot process
	unless ($dbh) {
		Err::DBI::Connect->throw( message => 'Cannot connect to DBMS: ' . $DBI::errstr );
	}

	# Set PostgreSQL default init queries
	$dbh->do("SET CLIENT_ENCODING TO 'UTF-8'");
	$dbh->do("SET DATESTYLE TO 'ISO'");

	return $dbh;

} ## end sub _connect

1;

