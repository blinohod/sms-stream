package Colibri::CME;

use 5.8.0;
use strict;
use warnings;

use version; our $VERSION = version->declare('v0.1.0');

use base 'Colibri::Base';
use POSIX qw(strftime);

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

# ===================== I/O MESSAGES =====================

sub msg_insert {

	my ( $this, %msg ) = @_;

	my $keys = join( ', ', keys %msg );
	my $vals = join( ', ', map { '?' } keys %msg );

	my $sql = "insert into stream.queue ($keys)	values ($vals) returning *";
	$this->trace( "========== SQL TRACE (msg_insert)\n%s\nParams: %s\n", $sql, join( ' : ', values %msg ) );

	my ($res) = $this->{dbh}->selectrow_hashref( $sql, undef, values %msg );
	return $res;

}

sub msg_update {

	my ( $this, $msg_id, %msg ) = @_;

	my $sql_fields = join( ',', map { "$_ = ?" } keys %msg );

	my $sql = "update stream.queue set $sql_fields where id = $msg_id returning *";
	$this->trace( "========== SQL TRACE (msg_update)\n%s\nParams: %s", $sql, join( ' : ', values %msg ) );

	my $res = $this->{dbh}->selectrow_hashref( $sql, undef, values %msg );

}

sub msg_fetch {

	my ( $this, $app_name, $status, $limit ) = @_;

	# Fetch single message unless limit defined
	$limit ||= 1;

	my $sql = "select q.* from stream.queue q
		join stream.apps a on (q.dst_app_id = a.id)
		where a.name = ? and q.status = ?
		order by id asc
		limit ?";

	$this->trace( "========== SQL TRACE (msg_fetch)\n%s\nParams: %s", $sql, join( ' : ', $app_name, $status, $limit ) );
	my $sth = $this->{dbh}->prepare($sql);
	$sth->execute( $app_name, $status, $limit );

	my @res = ();
	while ( my $row = $sth->fetchrow_hashref() ) {
		push( @res, $row );
		#$this->{dbh}->do( "update stream.queue set status = 'PROCESSING' where id = ?", undef, $row->{id} );
	}

	return @res;

} ## end sub msg_fetch

sub msg_get_by_id {

	my ( $this, $msg_id ) = @_;

	my $sql = "select * from stream.queue where id = ?";

	my $res = $this->{dbh}->selectrow_hashref( $sql, undef, $msg_id );

	return $res;

}

sub msg_fetch_incoming {

}

sub msg_fetch_outgoing {

	my ( $this, $app_name, $smsc_id, $limit ) = @_;

	# Fetch single message unless limit defined
	$limit ||= 1;

	my $sql = "select q.* from stream.queue q
		join stream.apps a on (q.dst_app_id = a.id)
		where a.name = ?
			and q.status = 'ROUTED'
			and q.smsc_id = ?
		order by prio desc, id asc
		limit ?";

	$this->trace( "========== SQL TRACE (msg_fetch_outgoing)\n%s\nParams: %s", $sql, join( ' : ', $app_name, $smsc_id, $limit ) );

	my $sth = $this->{dbh}->prepare($sql);
	$sth->execute( $app_name, $smsc_id, $limit );

	my @res = ();
	while ( my $row = $sth->fetchrow_hashref() ) {
		push( @res, $row );
	}

	return @res;

} ## end sub msg_fetch_outgoing

sub create_dlr {

	my ( $this, $orig, %params ) = @_;

	my %reply = (
		dir         => 'DLR',
		status      => 'ROUTED',                # Sure, we know where to send DLR
		ref_id      => $orig->{id},             # Original message ID
		customer_id => $orig->{customer_id},    # Original message ID
		src_app_id  => $orig->{dst_app_id},     # Should be ID of 'app_kannel'
		dst_app_id  => $orig->{src_app_id},     # Send to application generated original message
		src_addr    => $orig->{dst_addr},       # MSISDN
		dst_addr    => $orig->{src_addr},       # Source address (alphanumeric or short code)
		mno_id      => $orig->{mno_id},
		smsc_id     => $orig->{smsc_id},
		coding      => 0,
		mclass      => undef,
	);

	$reply{body} = $this->format_dlr_body(
		msg_id   => $orig->{id},
		date_sub => $params{date_sub},
		status   => $params{status},
		err      => $params{err},
	);

	$this->trace( 'DLR PREPARED:%s', Dumper( \%reply ) );

	$this->msg_insert(%reply);
} ## end sub create_dlr

# ===================== MESSAGES CONTENT =====================

sub format_dlr_body {

	my ( $this, %params ) = @_;

	my $msg_id   = $params{msg_id};
	my $date_sub = $params{date_sub};
	my $status   = $params{status};
	my $err      = $params{err} + 0;

	my $tmpl = "id:%d sub:001 dlvrd:001 submit date:%s done date:%s stat:%s err:%03d Text:%s";

	return sprintf( $tmpl, $msg_id, $this->format_dlr_date($date_sub), $this->format_dlr_date(), $status, $err, '' );

}

sub format_dlr_date {

	my ( $this, $date ) = @_;

	unless ($date) {
		return strftime( "%y%m%d%H%M", localtime );
	}

	if ( $date =~ /\d{2}(\d{2})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2})/ ) {
		return "$1$2$3$4$5";
	}

	return undef;

}

# ===================== CORE OBJECTS =====================

# Fetch app_id by name

sub get_app_id {

	my ( $this, $app_name ) = @_;

	my $sql = "select id from stream.apps where name=? limit 1";
	if ( my $res = $this->{dbh}->selectrow_hashref( $sql, undef, $app_name ) ) {
		return $res->{id};
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

# ===================== HLR LOOKUP AND ROUTING =====================

sub get_active_smsc {

	my ($this) = @_;
	my $sql = "select * from stream.smsc where active";
	return @{ $this->{dbh}->selectall_arrayref( $sql, { Slice => {} } ) };

}

sub find_direction {

	my ( $this, $msisdn ) = @_;

	my $sql = "select * from stream.directions where ? like prefix||'%' order by id limit 1";
	if ( my $row = $this->{dbh}->selectrow_hashref( $sql, undef, $msisdn ) ) {
		return $row;
	}
	return undef;

}

sub route_by_mno {

	my ( $this, $mno_id ) = @_;

	my $sql = "select smsc_id from stream.rules where mno_id = ?";

	if ( my $row = $this->{dbh}->selectrow_hashref( $sql, undef, $mno_id ) ) {
		return $row->{smsc_id};
	} else {
		$this->log( 'error', 'Cannot find SMSC for MNO=%s', $mno_id );
		return undef;
	}

}

sub route_by_mccmnc {

	my ( $this, $mcc, $mnc ) = @_;

	my $sql = "select r.smsc_id as smsc_id, r.mno_id as mno_id
			from stream.rules r
			join stream.networks n on (r.mno_id = n.mno_id)
			where n.mcc = ? and n.mnc = ?";

	my $row = $this->{dbh}->selectrow_hashref( $sql, undef, $mcc, $mnc );
	if ($row) {
		return wantarray ? ( $row->{smsc_id}, $row->{mno_id} ) : $row->{smsc_id};
	} else {
		$this->log( 'error', 'Cannot find SMSC for MCC=%s and MNC=%s', $mcc, $mnc );
		return undef;
	}

}

sub hlr_find_cached {

	my ( $this, $msisdn ) = @_;

	my $sql = "select * from stream.hlr_cache where msisdn = ? and expire > now()";
	if ( my ($cached) = $this->{dbh}->selectrow_hashref( $sql, undef, $msisdn ) ) {
		return $cached;
	} else {
		return undef;
	}

}

sub hlr_store {

	my ( $this, $msisdn, %params ) = @_;

	$this->{dbh}->do( "delete from stream.hlr_cache where msisdn = ?", undef, $msisdn );

	my $valid = $params{valid} + 0;    # is MSISDN valid
	my $mcc   = $params{mcc} + 0;      # Mobile Country Code
	my $mnc   = $params{mnc} + 0;      # Mobile Network Code
	my $imsi  = $params{imsi} . '';    # IMSI (SIM card ID)

	# Determine MNO first
	my ($mno_id) = $this->{dbh}->selectrow_array( "select stream.mno_by_mccmnc(?, ?) as mno", undef, $mcc, $mnc );

	$this->log( 'info', 'MNO by MCC/MNC: %s:%s => %s', $mcc, $mnc, $mno_id );

	my $sql = "insert into stream.hlr_cache (msisdn, valid, mcc, mnc, imsi, mno_id) values (?, ?, ?, ?, ?, ?) returning *";
	my $res = $this->{dbh}->selectrow_hashref( $sql, undef, $msisdn, $valid, $mcc, $mnc, $imsi, $mno_id );

	return $res;

} ## end sub hlr_store

sub get_rate {

	my ( $this, $customer_id, $mno_id ) = @_;

	my $sql = "select price from stream.rates
		where (customer_id = ? or customer_id is null)
		and mno_id = ?
		order by customer_id nulls last limit 1";

	if ( my $res = $this->{dbh}->selectrow_hashref( $sql, undef, $customer_id, $mno_id ) ) {
		return $res->{price};
	} else {
		return undef;
	}

}
1;

