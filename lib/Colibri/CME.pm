package Colibri::CME;

use 5.8.0;
use strict;
use warnings;

use version; our $VERSION = version->declare('v0.1.0');

use base 'Colibri::Base';

use Data::Dumper;

use constant DEFAULT_PACK_SIZE => 1;

sub new {

	my ( $class, %params ) = @_;

	unless ( $params{dbh} ) {
		Err::Argument->throw( message => 'Absent "dbh" argument in Colibri::CME constructor' );
	}

	my $this = $class->SUPER::new(
		%params,
	);

	return bless $this, $class;
}

sub insert {

	my ( $this, $app_name, $limit ) = @_;

}

sub fetch {

	my ( $this, $app_name, $status, $limit ) = @_;

	$limit ||= DEFAULT_PACK_SIZE;

	my $sql = "select q.*, a.name from stream.queue q
		join stream.apps a on (q.dst_app_id = a.id)
		where a.name = ? and q.status = ?
		order by id asc
		limit ?";

	my $sth = $this->{dbh}->prepare($sql);
	$sth->execute( 'app_hlr', 'ROUTED', $limit );

	my @res = ();
	while ( my $row = $sth->fetchrow_hashref() ) {
		push( @res, $row );
		$this->{dbh}->do( "update stream.queue set status = 'PROCESSING' where id = ?", undef, $row->{id} );
	}

	return @res;

} ## end sub fetch

# Fetch app_id by name
sub get_app_id {

	my ( $this, $app_name ) = @_;

	my $sql = "select id from stream.apps where name=? limit 1";
	if ( my $res = $this->{dbh}->selectrow_hashref( $sql, undef, $app_name ) ) {
		return $res->{id};
	}

	return undef;

}

sub find_direction {

	my ( $this, $msisdn ) = @_;

	my $sql = "select * from stream.directions where ? like prefix||'%' order by id limit 1";
	if ( my $row = $this->{dbh}->selectrow_hashref( $sql, undef, $msisdn ) ) {
		return $row;
	}
	return undef;

}

sub fail_msg {

	my ( $this, $id, $reason ) = @_;
}

sub format_dlr_body {

	my ( $this, %params ) = @_;

	my $date_sub = $params{date_sub};

	my $tmpl = "id:%d sub:001 dlvrd:001 submit date:%s done date:%s stat:%s err:%03d Text:%s";

	printf( $tmpl, 12345, $date_sub, 'YYMMDDhhmm', 'DELIVRD', 0, 'Text here' );

}

sub format_dlr_date {

	my ( $this, $date ) = @_;

	if ( $date =~ /\d{2}(\d{2})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2})/ ) {
		return "$1$2$3$4$5";
	}

	return undef;

}

sub auth_esme {

	my ( $this, $system_id, $password, $remote_ip ) = @_;

	my $sql = "select * from stream.customers where login=? and password=? and active limit 1";
	if ( my $res = $this->{dbh}->selectrow_hashref( $sql, undef, $system_id, $password ) ) {
		return $res;
	} else {
		return undef;
	}

}

1;

