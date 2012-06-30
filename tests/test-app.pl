#!/usr/bin/env perl 

use 5.8.0;
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Data::Dumper;

use base 'Colibri::App';

use version; our $VERSION = version->declare('v0.1.0');

__PACKAGE__->debug(1);
__PACKAGE__->run_app(infinite => 0, pid_file => '/tmp/zz.pid', );

#$logger->log( 'error', 'Error message' );

1;

__END__

=head1 SYNOPSIS

Opa


=cut
