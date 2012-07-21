#!/usr/bin/env perl 

use 5.8.0;
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Data::Dumper;

use Colibri::DBI;
use Colibri::CME;

my $db = Colibri::DBI->get_dbh(
	host   => '192.168.1.53',
	port   => 5432,
	user   => 'misha',
	passwd => '',
	dbname => 'stream'
);

print Dumper($db);

my $cme = Colibri::CME->new(
	dbh => $db,
);

warn Dumper($cme);

warn Dumper( $cme->get_app_id('app_hlr') );

$cme->format_dlr_body();

1;

