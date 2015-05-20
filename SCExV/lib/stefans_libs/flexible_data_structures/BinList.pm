package stefans_libs::flexible_data_structures::BinList;
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
use stefans_libs::root;

=for comment

This document is in Pod format.  To read this, use a Pod formatter,
like 'perldoc perlpod'.

=head1 NAME

stefans_libs_flexible_data_structures_BinList

=head1 DESCRIPTION

The bin List is a tool, that can sum up two dimensional data and group the data poinst based on the x information. The user is able to define the summary functions AddValue() and Finalize(). This object is used in the histogram plotting.

=head2 depends on


=cut


=head1 METHODS

=head2 new

new returns a new object reference of the class stefans_libs_flexible_data_structures_BinList.

=cut

sub new{

	my ( $class ) = @_;

	my ( $self );

	$self = {
		'category_steps' => 100, ## the list has per default 100 bins!
		'data_counter' => 0,
  	};

  	bless $self, $class  if ( $class eq "stefans_libs::flexible_data_structures::BinList" );

  	return $self;

}

sub AddValue {
	my ( $self, $value ) = @_;
	Carp::confess ( "This function has to be implemented in the child!");
	return unless ( defined $value );
	@{$self->{'data'}}[$self->_box($value)] ++;
	$self->Y_Max ( @{$self->{'data'}}[$self->_box($value)] );
	return 1;
}

sub Finalize {
	my ( $self ) = 	@_;
	Carp::confess ( "This function has to be implemented in the child!");
	return 1;
}

sub steps {
	my ( $self, $steps ) = @_;
	if ( defined $steps ) {
		unless ( $self->{'category_steps'} == $steps ) {
			$self->{'category_steps'} = $steps;
			$self->{'bins'} = undef;
		}
	}
	return $self->{'category_steps'};
}

=head3 _box( value )

returns the storage id for the value.

=cut

sub _box {
	my ( $self, $value ) = @_;
	return int( ($value - $self->X_Min()) / ( $self->X_Max() - $self->X_Min() ) * $self->steps() );
}

sub __we_contain_data {
	my ($self) = @_;
	return 0 unless ( ref($self->{'data'}) eq "ARRAY");    ## if we do not contain data
	return 1;    ## if we do contain data
}

sub initialize {
	my $self = shift;
	unless ( $self->X_Max() ) {
		Carp::confess ( "Sorry, but you first need to give me the X_Min and X_Max values!") ;
	}
	if ( ref( $self->{bins} ) eq "ARRAY" ) {
		for ( my $i = 0; $i < @{$self->{data}}; $i ++) {
			@{$self->{'data'}}[$i] = 0;
		}
		return $self->{data}, $self->{bins};
	}
	$self->{stepSize} =
	  ( ( $self->X_Max() - $self->X_Min() ) / $self->steps() );
	
	my ( $iterator );
	$self->{data} = [];
	$self->{bins} = [];
	$iterator = 0;
	for ( my $i = $self->X_Min() ; $i < $self->X_Max() ; $i += $self->{stepSize} ) {
		@{$self->{data}}[$iterator] = 0;
		@{$self->{bins}}[$iterator] = [$i, $i + $self->{stepSize}];
		$iterator++;
	}
	return $self->{data}, $self->{bins};
}

=head2 CreateHistogram ( [values] )

This function will load all data into the histogram

=cut

sub CreateHistogram {
	my ( $self, $array ) = @_;
	Carp::confess( "I need an array of values to create the histogram!" ) unless ( ref($array) eq "ARRAY" );
	$self->Y_Min('initialize');
	$self->Y_Max('initialize');
	$self->{'data_counter'} ++;
	foreach ( @$array ){
		$self->X_Min($_);
		$self->X_Max($_);
	}
	$self->initialize();
	foreach ( @$array ){
		$self->AddValue( $_ );
	}
	$self->Finalize();
}

sub X_Max {
	my ( $self, $max ) = @_;
	if ( defined $max ) {
		$self->{'x_max'} = $max unless ( defined $self->{'x_max'} );
		$self->{'error'} .=
		  ref($self) . ":max -> this value is not a number ($max)\n"
		  unless ( $max =~ m/^[\d\.,Ee\-\+]+$/ );
		$self->{'x_max'} = $max if ( $self->{'x_max'} < $max );
	}
	return $self->{'x_max'};

}
sub X_Min {
	my ( $self, $min ) = @_;
	if ( defined $min ) {
		$self->{'x_min'} = $min unless ( defined $self->{'x_min'} );
		$self->{'error'} .=
		  ref($self) . ":min -> this value is not a number ($min)\n"
		  unless ( $min =~ m/^[\d\.,Ee\-\+]+$/ );
		$self->{'x_min'} = $min if ( $self->{'x_min'} > $min );
	}
	return $self->{'x_min'};
}

sub Y_Max {
	my ( $self, $value ) = @_;
	return $self->{'max'} unless ( defined $value );
	if ( $value eq "initialize") {
		$self->{'max'} = undef;
		return 1;
	}
	unless ( defined $self->{'max'} ) {
		$self->{'max'} = $value;
	}
	elsif ( $self->{'max'}< $value) {
		$self->{'max'} = $value;
	}
	return $self->{'max'};
}

sub Y_Min {
	my ( $self, $value ) = @_;
	return $self->{'min'} unless ( defined $value );
	if ( $value eq "initialize") {
		$self->{'min'} = undef;
		return 1;
	}
	unless ( defined $self->{'min'} ) {
		$self->{'min'} = $value;
	}
	elsif ( $self->{'min'} > $value) {
		$self->{'min'} = $value;
	}
	return $self->{'min'};
}


1;
