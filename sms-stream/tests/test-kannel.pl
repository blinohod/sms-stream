#!/usr/bin/env perl 

use 5.8.0;
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Data::Dumper;

use Colibri::Kannel;

my $kannel = Colibri::Kannel->new(
	sendsms_url    => 'http://192.168.1.50:13013/cgi-bin/sendsms',
	sendsms_user   => 'local',
	sendsms_passwd => 'local',
	dlr_url        => 'http://127.0.0.1/stream/recv',
);

print Dumper($kannel);

print Dumper(
	$kannel->send(
		from => 'Tester',
		to   => '38012345435345',
		smsc => 'fake-smsc',
		text => 'Opa',
	)
);

1;

