package stefans_libs::flexible_data_structures::BinList::Histogram;
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

stefans_libs::flexible_data_structures::BinList::Histogram

=head1 DESCRIPTION

This is a bin list that can be used to create histogram type of data summaries. Using a simple counting of values.

=head2 depends on


=cut


=head1 METHODS

=head2 new

new returns a new object reference of the class stefans_libs::flexible_data_structures::BinList::Histogram.

=cut

sub new{

	my ( $class ) = @_;

	my ( $self );

	$self = {
		'category_steps' => 100, ## the list has per default 100 bins!
		'data_counter' => 0,
  	};

  	bless $self, $class  if ( $class eq "stefans_libs::flexible_data_structures::BinList::Histogram" );

  	return $self;

}

#########################################################
### important to overload from the 'stefans_libs::flexible_data_structures::BinList' class

sub AddValue {
	my ( $self, $value ) = @_;
	return unless ( defined $value );
	@{$self->{'data'}}[$self->_box($value)] ++;
	$self->Y_Max ( @{$self->{'data'}}[$self->_box($value)] );
	return 1;
}
sub Finalize {
	my ( $self ) = 	@_;
	## No data processing necessary!
	return 1;
}

### overload done
##########################################################

1;
