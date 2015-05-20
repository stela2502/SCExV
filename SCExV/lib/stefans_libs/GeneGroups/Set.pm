package stefans_libs::GeneGroups::Set;

#  Copyright (C) 2014-05-23 Stefan Lang

#  This program is free software; you can redistribute it
#  and/or modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation;
#  either version 3 of the License, or (at your option) any later version.

#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#  See the GNU General Public License for more details.

#  You should have received a copy of the GNU General Public License
#  along with this program; if not, see <http://www.gnu.org/licenses/>.

#use FindBin;
#use lib "$FindBin::Bin/../lib/";
use strict;
use warnings;
use Carp;

=for comment

This document is in Pod format.  To read this, use a Pod formatter,
like 'perldoc perlpod'.

=head1 NAME

stefans_libs::GeneGroups::Set

=head1 DESCRIPTION

This object contains all data to create 2D groups in a table based in two keys. This object is just storing the data - it has no connection to the data source table.

=head2 depends on


=cut

=head1 METHODS

=head2 new

new returns a new object reference of the class stefans_libs::GeneGroups::Set.

=cut

sub new {

	my ( $class, $gene1, $gene2 ) = @_;

	my ($self);
	Carp::confess("I need two genes at startup!") unless ( defined $gene2 );

	$self = {
		'g1'     => $gene1,
		'g2'     => $gene2,
		'groups' => [],
		'exists' => {},
	};

	bless $self, $class if ( $class eq "stefans_libs::GeneGroups::Set" );

	return $self;

}

sub nGroup {
	my ($self) = @_;
	return scalar( @{ $self->{'groups'} } );
}

sub group_samples{
	my ( $self, $table ) =@_;
	my ( $posA, $posB, $names, $ret, $used );
	$posA = $table->Header_Position( $self->{'g1'} );
	$posB = $table->Header_Position( $self->{'g2'} );
	## Samples == pos 0
	$ret = { map{ $_ => [] } 0..@{$self->{'groups'}} };
	for ( my $i = 0; $i < $table->Rows(); $i ++ ){
		$used = 0;
		for ( my $a = 1; $a <= @{$self->{'groups'}} ; $a++ ){
			if ( $self->match_2_group( @{@{$table->{'data'}}[$i]}[$posA,$posB], $a ) ){
				push( @{$ret->{$a}}, @{@{$table->{'data'}}[$i]}[0] );
				$used ++;
			}
			
		}
		push( @{$ret->{0}}, @{@{$table->{'data'}}[$i]}[0] ) unless ( $used );
	}
	return $ret;
}

sub match_2_group {
	my ( $self, $value1, $value2, $group_id ) = @_;
	$group_id--;
	return 1
	  if ((
		(
			   @{ @{ $self->{'groups'} }[$group_id] }[0] <= $value1
			&& @{ @{ $self->{'groups'} }[$group_id] }[1] >= $value1
		)
		&& (   @{ @{ $self->{'groups'} }[$group_id] }[2] <= $value2
			&& @{ @{ $self->{'groups'} }[$group_id] }[3] >= $value2 )
	  ));
	return 0;
}

sub group {
	my ( $self, $group_id ) = @_;
	$group_id--;
	return {
		'x1' => @{ @{ $self->{'groups'} }[$group_id] }[0],
		'x2' => @{ @{ $self->{'groups'} }[$group_id] }[1],
		'y1' => @{ @{ $self->{'groups'} }[$group_id] }[2],
		'y2' => @{ @{ $self->{'groups'} }[$group_id] }[3]
	};
}

sub AsString {
	my ($self) = @_;
	my $s = "markers\t$self->{'g1'}\t$self->{'g2'}\n" . $self->extends('print');
	my $i = 1;
	foreach ( @{ $self->{'groups'} } ) {
		$s .= "Gr" . $i++ . "\t" . join( "\t", @$_ ) . "\n";
	}
	return $s;
}

sub export_R {
	my ( $self, $GeneGroups, $rObj, $group_id ) = @_;
	my $script =
	    "p1 <- which ( colnames($rObj) == '$self->{'g1'}' )\n"
	  . "p2 <- which ( colnames($rObj) == '$self->{'g2'}' )\n";
	foreach ( @{ $self->{'groups'} } ) {
		$script .=
		    "now <- as.vector( which( ( $rObj"
		  . "[,p1] >= @$_[0] & $rObj"
		  . "[,p1] <= @$_[1] ) & "
		  . "( $rObj"
		  . "[,p2] >= @$_[2] & $rObj"
		  . "[,p2] <= @$_[3] ) ))\n";
		$script .=
		    "userGroups\$userInput[now] = '"
		  . join( " ", $self->{'g1'}, $self->{'g2'}, @$_ ) . "'\n"
		  . "userGroups\$groupID[now] = "
		  . ( $group_id++ ) . "\n";
	}
	return $script;
}

sub export_R_exclude_samples {
	my ( $self, $GeneGroups, $rObj, $group_id ) = @_;
	my $script =
	    "p1 <- which ( colnames($rObj) == '$self->{'g1'}' )\n"
	  . "p2 <- which ( colnames($rObj) == '$self->{'g2'}' )\n";
	foreach ( @{ $self->{'groups'} } ) {
		$script .=
		    "now <- as.vector( which( ( $rObj"
		  . "[,p1] >= @$_[0] & $rObj"
		  . "[,p1] <= @$_[1] ) & "
		  . "( $rObj"
		  . "[,p2] >= @$_[2] & $rObj"
		  . "[,p2] <= @$_[3] ) ))\n";
		$script .= "excludeGroups\$groupID[now] = "
		  . ( $group_id++ ) . "\n";
	}
	return $script;
}

sub extends {
	my ( $self, $array ) = @_;
	if ( $array eq "print" ) {
		return "extends\tnothing\n"
		  unless ( ref( $self->{'_extends'} ) eq 'ARRAY' );
		return
		  join( "\t", 'extends', join( "\t", @{ $self->{'_extends'} } ) )
		  . "\n";
	}
	elsif ( ref($array) eq "ARRAY" ) {
		if ( @$array == 1 ) {
			$self->{'_extends'} = ['nothing'];
		}
		else {
			my $e = '';
			$e .= 'not 3 values!\n' unless ( @$array == 3 );
			$e .= 'third value not a int' unless ( @$array[2] =~ m/^\d\d+$/ );
			Carp::confess("ERROR: $e\n") if ( $e =~ m/\w/ );
			$self->{'_extends'} = $array;
		}
	}
	return $self->{'_extends'};
}

sub AddGroup {
	my ( $self, $x1, $x2, $y1, $y2 ) = @_;
	( $x1, $x2 ) = sort { $a <=> $b } ( $x1, $x2 );
	( $y1, $y2 ) = sort { $a <=> $b } ( $y1, $y2 );
	return $self->{'exists'}->{"$x1,$x2,$y1,$y2"}
	  if ( defined $self->{'exists'}->{"$x1,$x2,$y1,$y2"} );
	push( @{ $self->{'groups'} }, [ $x1, $x2, $y1, $y2 ] );
	$self->{'exists'}->{"$x1,$x2,$y1,$y2"} = scalar( @{ $self->{'groups'} } );
	return scalar @{ $self->{'groups'} };
}

sub processArray {
	my ( $self, $array ) = @_;
	my $key = shift(@$array);
	if ( $key =~ m/Gr(\d+)/ ) {
		my $g = $self->AddGroup(@$array);
		Carp::confess( "I could not add the line "
			  . join( "\t", @$array )
			  . " as group $1 but as group $g!\n" )
		  unless ( $g == $1 );
	}
	else {
		$self->$key($array);
	}
	return 1;
}

1;
