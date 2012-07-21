#!/usr/bin/env perl 

use 5.8.0;
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Data::Dumper;

use base 'Colibri::App::FCGI';

use version; our $VERSION = version->declare('v0.1.0');

__PACKAGE__->debug(1);
__PACKAGE__->run_app();

sub process {

	my ($this, $cgi) = @_;

	warn Dumper($this->cgi);

}


1;

__END__

=head1 SYNOPSIS

Opa


=cut
