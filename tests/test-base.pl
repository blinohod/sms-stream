#!/usr/bin/env perl 

use 5.8.0;
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Data::Dumper;

use Colibri::Logger;

my $logger = Colibri::Logger->new();

$logger->log('info', 'Info message');
$logger->log('warning', 'Warning message');
$logger->log('err', 'Error message');

1;


