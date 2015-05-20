package stefans_libs::Description;
#  Copyright (C) 2014-06-11 Stefan Lang

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


=for comment

This document is in Pod format.  To read this, use a Pod formatter,
like 'perldoc perlpod'.

=head1 NAME

stefans_libs::Description

=head1 DESCRIPTION

This class uses the HTpcrA result fiolder to create a descriptive HTML document that can be written to the archive. The HTML parsing is mainly performed in the Files controler. This class is just performing all the other tasks.

=head2 depends on


=cut


=head1 METHODS

=head2 new

new returns a new object reference of the class stefans_libs::Description.

=cut

sub new{

	my ( $class ) = @_;

	my ( $self );

	$self = {
  	};

  	bless $self, $class  if ( $class eq "stefans_libs::Description" );

  	return $self;

}


1;
