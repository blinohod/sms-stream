#!/usr/bin/env perl 
use 5.8.0;
use strict;
use warnings;

use Data::Dumper;
use Text::CSV;

use DBI;

my $dbh = DBI->connect( 'dbi:Pg:dbname=stream;host=192.168.1.53', 'misha', '', { RaiseError => 1, } );

my $csv = Text::CSV->new( { binary => 1 } )    # should set binary attribute.
  or die "Cannot use CSV: " . Text::CSV->error_diag();

my $country = '';
my $cid     = undef;

$dbh->begin_work;

while (<STDIN>) {

	my $status = $csv->parse($_);
	unless ($status) {
		warn "Cannot parse CSV line: $_\n";
		next;
	}

	my ( $who, $mcc_mnc ) = $csv->fields();

	unless ($mcc_mnc) {
		$country = $who;
		next;
	}

	my $mno = $who;
	$mno =~ s/^\s*//g;
	$mno =~ s/\s*$//g;

	if ( $mcc_mnc =~ /^\s*(\d+)\s+(\d+)\s*$/ ) {
		my $mcc = $1;
		my $mnc = $2;

		my $sql = "insert into stream.networks (mcc,mnc,ctr,oper) values (?, ?, ?, ?) returning *";
		eval { my $row = $dbh->selectrow_hashref( $sql, undef, $mcc, $mnc, $country, $mno ); };
		if ($@) {
			warn "Country: $country; MNO: $mno; MCC: $mcc; MNC: $mnc\n";
		}
		#warn Dumper($row);
		#$cid = $row->{id};
		#warn "Country: $country; MNO: $mno; MCC: $mcc; MNC: $mnc\n";

	}

} ## end while (<STDIN>)

$dbh->commit;

1;
