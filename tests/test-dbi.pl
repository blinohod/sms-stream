#!/usr/bin/env perl 

use 5.8.0;
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Data::Dumper;

use Colibri::DBI;

my $db = Colibri::DBI->get_dbh(
	host => '192.168.1.53',
	port => 5432,
	user => 'misha',
	passwd => '',
	dbname => 'stream'
);

print Dumper($db);

warn Dumper($db->selectrow_hashref("select * from stream.countries"));

1;


