package Colibri::Utils;

use 5.8.0;
use strict;
use warnings;

use version; our $VERSION = version->declare('v0.1.0');

use base 'Exporter';

our @EXPORT = qw(
  str_to_utf8
  utf8_to_str
  str_recode
  str_clean
  str_to_bcd
  chr_to_hex
  hex_to_chr
  str_to_hex
  hex_to_str
  str_to_base64
  base64_to_str
  str_to_uri
  uri_to_str
  is_int

  is_handle
  reset_handle
  file_open
  file_read
  file_write
  file_copy
  file_move
  file_temp
  dir_create
  dir_delete
  dir_read
  dir_read_recursive
  exec_external

);

use Encode qw(
  encode
  decode
  from_to
  is_utf8
);

use MIME::Base64;
use URI::Escape;
use POSIX;
use File::Spec;
use File::Copy;
use File::Path;
use File::Temp ();

sub str_to_utf8 {

	my ( $str, $enc ) = @_;

	if ( defined($str) and ( $str ne '' ) ) {
		unless ( is_utf8($str) ) {
			$str = decode( $enc || 'UTF-8', $str );
		}
	}

	return $str;

}

sub utf8_to_str {

	my ( $str, $enc ) = @_;

	if ( defined($str) and ( $str ne '' ) ) {
		if ( is_utf8($str) ) {
			$str = encode( $enc || 'UTF-8', $str );
		}
	}

	return $str;

}

sub str_recode {

	my ( $str, $from, $to ) = @_;

	if ( defined($str) and ( $str ne '' ) ) {
		if ($from) {
			my $len = from_to( $str, $from, $to );
			unless ( defined($len) ) {
				$str = undef;
			}
		}
	}

	return $str;

}

sub str_clean {

	my ($str) = @_;

	if ( defined($str) and ( $str ne '' ) ) {
		$str =~ s/^\s+//s;
		$str =~ s/\s+$//s;
		$str =~ s/\s+/ /gs;
	}

	return $str;
}

sub str_to_bcd {
	my ($str) = @_;
	$str = "$str" . 'F' x ( length("$str") % 2 );
	$str =~ s/([\dF])([\dF])/$2$1/g;
	return hex_to_str($str);
}

sub chr_to_hex {
	my ($chr) = @_;
	return defined($chr) ? uc( unpack( "H2", "$chr" ) ) : "$chr";
}

sub hex_to_chr {
	my ($hex) = @_;
	return defined($hex) ? pack( "H2", "$hex" ) : "$hex";
}

sub str_to_hex {
	my ($str) = @_;
	return defined($str) ? uc( unpack( "H*", "$str" ) ) : "";
}

sub hex_to_str {
	my ($hex) = @_;
	return defined($hex) ? pack( "H*", "$hex" ) : "";    #"$hex";
}

sub str_to_base64 {
	my ($str) = @_;
	return encode_base64( $str, "" );
}

sub base64_to_str {
	my ($str) = @_;
	return decode_base64($str);
}

sub str_to_uri {
	my ($str) = @_;
	return uri_escape( $str, "\x00-\xff" );
}

sub uri_to_str {
	my ($str) = @_;
	return uri_unescape($str);
}

sub is_int {
	my ($value) = @_;
	return 0 unless defined $value;
	return ( ( $value =~ /^[-+]?\d+$/ ) and ( $value >= INT_MIN ) and ( $value <= INT_MAX ) ) ? 1 : 0;
}

sub is_handle {
	my ( $fh, @list ) = @_;

	push( @list, qw(IO::Scalar IO::Handle GLOB) );
	foreach my $class (@list) {
		if ( UNIVERSAL::isa( $fh, $class ) ) {
			return 1;
		}
	}

	return 0;
}

sub reset_handle {
	my ($fh) = @_;

	if ( $fh->can('binmode') ) {
		$fh->binmode;
	} else {
		binmode($fh);
	}

	if ( $fh->can('seek') ) {
		$fh->seek( 0, 0 );
	}
}

sub file_open {
	my $fil = shift;

	my $fh;
	my $st = 1;
	if ( ref($fil) ) {
		if ( is_handle($fil) ) {
			$fh = $fil;
		} else {
			require IO::File;
			$fh = IO::File->new;
			$st = $fh->fdopen( $fil, @_ );
		}
	} else {
		require IO::File;
		$fh = IO::File->new;
		$st = $fh->open( $fil, @_ );
	}

	if ($st) {
		reset_handle($fh);
	} else {
		return undef;
	}

	return $fh;
} ## end sub file_open

sub file_read {
	my $fil = shift;

	my $bin = undef;

	my $fh = file_open( $fil, ( scalar(@_) > 0 ) ? @_ : 'r' );

	if ( defined($fh) ) {
		local $/ = undef;
		$bin = <$fh>;
		$fh->close;
		$/ = "\n";
	}

	return $bin;
}

sub file_write {
	my $fil = shift;
	my $bin = shift;

	my $fh = file_open( $fil, ( scalar(@_) > 0 ) ? @_ : 'w+' );

	if ( defined($fh) ) {
		$fh->print($bin);
		$fh->close;
		return bytes::length($bin);
	} else {
		return undef;
	}
}

sub file_copy {
	my ( $ifl, $ofl ) = @_;

	if ( is_handle($ifl) ) {
		reset_handle($ifl);
	}

	if ( copy( $ifl, $ofl ) ) {
		return 1;
	} else {
		return undef;
	}
}

sub file_move {
	my ( $ifl, $ofl ) = @_;

	if ( is_handle($ifl) ) {
		reset_handle($ifl);
	}

	if ( move( $ifl, $ofl ) ) {
		return 1;
	} else {
		return undef;
	}
}

sub file_temp {

	my ($dir) = @_;

	my %params = ();
	if ($dir) { $params{DIR} = $dir; }

	my $fh = File::Temp->new(%params);

	return $fh;

}

sub dir_create {
	my ( $dir, $mode ) = @_;
	$mode ||= 0777 & ~umask();

	my $ret = '';
	eval { $ret = mkpath( $dir, 0, $mode ); };
	if ($@) {
		return undef;
	}

	return $dir;
}

sub dir_delete {
	my ($dir) = @_;

	my $ret = '';
	eval { $ret = rmtree( $dir, 0, 1 ); };
	if ($@) {
		return undef;
	}

	return $dir;
}

sub dir_read {
	my ( $dir, $end ) = @_;

	if ( opendir( DIR, $dir ) ) {
		my @con =
		  ( defined($end) )
		  ? sort grep { $_ !~ m/^[.]{1,2}$/ and $_ =~ m/^.+\.$end$/i } readdir(DIR)
		  : sort grep { $_ !~ m/^[.]{1,2}$/ } readdir(DIR);

		closedir(DIR);

		return \@con;
	} else {
		return undef;
	}
}

sub dir_read_recursive {
	my ( $dir, $ext, $res ) = @_;
	$res ||= [];

	my $con = dir_read($dir);
	if ( defined($con) ) {
		foreach my $nam ( @{$con} ) {
			my $fil = "$dir/$nam";
			if ( -d $fil ) {
				dir_read_recursive( $fil, $ext, $res );
			} elsif ( $nam =~ m/^.+\.$ext$/i ) {
				push( @{$res}, $fil );
			}
		}

		return $res;
	} else {
		return undef;
	}
} ## end sub dir_read_recursive

sub exec_external {

	my $rc = system(@_);

	if ( $rc == -1 ) {
		return undef;
	} elsif ( $rc & 127 ) {
		return undef;
	} else {
		my $cd = $rc >> 8;
		if ( $cd == 0 ) {
			return 1;
		} else {
			return undef;
		}
	}
}

1;

