package stefans_libs::flexible_data_structures::BinList::XY_Group;
#  Copyright (C) 2013-01-22 Stefan Lang

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

use stefans_libs::flexible_data_structures::BinList;
use base ('stefans_libs::flexible_data_structures::BinList');

=for comment

This document is in Pod format.  To read this, use a Pod formatter,
like 'perldoc perlpod'.

=head1 NAME

stefans_libs::flexible_data_structures::BinList::XY_Group

=head1 DESCRIPTION

This is a BinList that can be used to sum up XY data and create a X mean(Y) STD(Y) type of data summaries.

=head2 depends on


=cut


=head1 METHODS

=head2 new

new returns a new object reference of the class stefans_libs::flexible_data_structures::BinList::XY_Group.

=cut

sub new{

	my ( $class ) = @_;

	my ( $self );

	$self = {
		'category_steps' => 100, ## the list has per default 100 bins!
		'data_counter' => 0,
  	};

  	bless $self, $class  if ( $class eq "stefans_libs::flexible_data_structures::BinList::XY_Group" );

  	return $self;

}

sub As_XY_data{
	my ( $self ) = @_;
	my $dataset = {'x' => [],'y' => [], 'stdAbw' => []};
	#@{$self->{data}}[$iterator] = 0;
	#@{$self->{bins}}[$iterator] = [$i, $i + $self->{stepSize}];
	my $iterator = 0;
	#print "\$exp = ".root->print_perl_var_def( { 'bins' => $self->{'bins'}, 'data' => $self->{'data'} } ).";\n";
	for (my $i = 0; $i < @{$self->{bins}}; $i ++ ){
		next if ( @{$self->{data}}[$i] == 0 ); ## this data value was untouched!
		Carp::confess( "I have an missing array on bin $i\n") unless ( ref( @{$self->{bins}}[$i]) eq "ARRAY");
		@{$dataset->{'x'}}[$iterator] = ( @{@{$self->{bins}}[$i]}[0] + @{@{$self->{bins}}[$i]}[1]) / 2;
		@{$dataset->{'y'}}[$iterator] = @{@{$self->{data}}[$i]}[0];
		unless (@{@{$self->{data}}[$i]}[2] eq "Undef") {
			@{$dataset->{'stdAbw'}}[$iterator] = @{@{$self->{data}}[$i]}[2];
		}
		else {
			@{$dataset->{'stdAbw'}}[$iterator] = 0;
		}
		$iterator ++;
	}
	return $dataset;
}

#########################################################
### important to overload from the 'stefans_libs::flexible_data_structures::BinList' class
sub AddValue {
	my ( $self, $valueX, $valueY ) = @_;
	return unless ( defined $valueX );
	Carp::confess ( "Sorry, but I need a a x and a y value not '$valueX/$valueY' $self->{'infos'}\n") unless ( defined $valueY);
	@{$self->{'data'}}[$self->_box($valueX)] = [] unless ( ref (@{$self->{'data'}}[$self->_box($valueX)]) eq "ARRAY" );
	push ( @{@{$self->{'data'}}[$self->_box($valueX)]}, $valueY );
	return 1;
}
sub Finalize {
	my ( $self ) = 	@_;
	## No data processing necessary!
	my ( $mean, $n, $std );
	for ( my $i = 0; $i < scalar ( @{$self->{'data'}} ); $i++ ){
		next unless ( ref(@{$self->{'data'}}[$i]) eq "ARRAY" ); ## this data point has not been touched during the addin of data!
		( $mean, $n, $std ) = root->getStandardDeviation( @{$self->{'data'}}[$i] );
		@{$self->{'data'}}[$i] = [ $mean, $n, $std ];
		$std = 0 if ( $std eq "Undef" );
		$self->Y_Max ( $mean + $std );
		$self->max_mean( $mean );
	}
	return 1;
}

sub max_mean {
	my ( $self, $value ) = @_;
	return $self->{'max_mean'} unless ( defined $value );
	if ( $value eq "initialize") {
		$self->{'max_mean'} = undef;
		return 1;
	}
	unless ( defined $self->{'max'} ) {
		$self->{'max_mean'} = $value;
	}
	elsif ( $self->{'max_mean'}< $value) {
		$self->{'max_mean'} = $value;
	}
	return $self->{'max_mean'};
}

sub CreateHistogram {
	my ( $self, $arrayX, $arrayY ) = @_;
	Carp::confess( "I need an array of X values to create the histogram!" ) unless ( ref($arrayX) eq "ARRAY" );
	Carp::confess( "I need an array of Y values to create the histogram!" ) unless ( ref($arrayY) eq "ARRAY" );
	$self->{'data_counter'} ++;
	unless ( defined $self->Y_Min()){
		$self->Y_Min('initialize');
		$self->Y_Max('initialize');
	}
	
	foreach ( @$arrayX ){
		$self->X_Min($_);
		$self->X_Max($_);
	}
	$self->initialize();
	$self->{'infos'} .= "Values X: ". join(",",@$arrayX)."\n";
	$self->{'infos'} .= "Values Y: ". join(",",@$arrayY)."\n";
	for (my $i = 0; $i <scalar( @$arrayX); $i++ ){
		$self->AddValue( @$arrayX[$i], @$arrayY[$i] );
	}
	$self->Finalize();
}
### overload done
##########################################################

1;
