package arraySorter;

#  Copyright (C) 2008 Stefan Lang

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

use strict;

sub new {

	my ($class, $debug) = @_;

	my ($self);

	$self = { debug => $debug };

	bless $self, $class if ( $class eq "arraySorter" );

	return $self;

}

sub sortHashListBy {
	my ( $self, $sortOrderArray, @hashList ) = @_;
	unless ( ref($self) eq "arraySorter" ) {
		unshift( @hashList, $sortOrderArray );
		$sortOrderArray = $self;
		$self           = undef;
	}
	my ($sortOrder, $value, $i, $matchStart);
	$sortOrder = shift(@$sortOrderArray);
	die
"arraySorter::sortArrayBy(\$sortOrder, \@matrix) needs a array of sortOrders\n",
	  "of the type { position => <position in the lineArray to evaluate>,",
	  " type => <either 'numeric', 'antiNumeric' or 'lexical'>},\n",
	  "not $sortOrder->{position} and $sortOrder->{type}\n"
	  unless ( defined $sortOrder->{position}
		&& ( "lexical numeric antiNumeric" =~ m/$sortOrder->{test}/ ) );
		
	if ( $sortOrder->{type} eq "numeric" ) {
		@hashList = (
			sort {
				$a->{$sortOrder->{position}} <=> $b->{$sortOrder->{position}}
			  } @hashList
		);
	}
	elsif ( $sortOrder->{type} eq "lexical" ) {
		@hashList = (
			sort {
				$a->{$sortOrder->{position}} cmp $b->{$sortOrder->{position}}
			  } @hashList
		);
	}
	elsif ( $sortOrder->{type} eq "antiNumeric" ) {
		@hashList = (
			sort {
				$b->{$sortOrder->{position}} <=> $a->{$sortOrder->{position}}
			  } @hashList
		);
	}
	
	$i = $matchStart = 0;
	$value = $hashList[0]->{$sortOrder->{position}};

	if ( defined @$sortOrderArray[0] ) {

		for ( $i = 1 ; $i < @hashList ; $i++ ) {

			unless ( $value eq $hashList[$i]->{$sortOrder->{position}} ) {
				$value = $hashList[$i]->{$sortOrder->{position}} ;
				unless ( $i - $matchStart == 1 ) {
					splice(
						@hashList,
						$matchStart,
						0,
						&sortArrayBy(
							$sortOrderArray,
							splice( @hashList, $matchStart, $i - $matchStart ),
						)
					);
				}
				$matchStart = $i;
			}
		}
		unless ( $i - $matchStart == 1 ) {
			splice(
				@hashList,
				$matchStart,
				$i - $matchStart,
				&sortArrayBy(
					$sortOrderArray,
					splice( @hashList, $matchStart, $i - $matchStart ),
				)
			);
		}

	}
	unshift( @$sortOrderArray, $sortOrder );
	return @hashList;
}

=head2 sortArrayBy

This function expects an array or sort orders, that should be applied to the following array or arrays.
The sort orders have to be an array of hashes like 
{ 
	'type' => one of (numeric,lexical,antiNumeric),
	'position' => the position of the sort string in the array
}.

The array of arrays will be resorted according to the sort orders and and array or arrays will be returned 
- NOT the ref to the matrix!

=cut

sub sortArrayBy {
	my ( $self, $sortOrderArray, @matrix ) = @_;
	my ( $value, $sortOrder, $matchStart );

	unless ( ref($self) eq "arraySorter" ) {
		unshift( @matrix, $sortOrderArray );
		$sortOrderArray = $self;
		$self           = undef;
	}
	$sortOrder = shift(@$sortOrderArray);

	print
"SortOrder: position = $sortOrder->{position}; type = $sortOrder->{type}\n" if ( $self->{'debug'});

	die
"arraySorter::sortArrayBy(\$sortOrder, \@matrix) needs a array of sortOrders\n",
"of the type { position => <position in the lineArray to evaluate>, type => <either 'numeric', 'antiNumeric' or 'lexical'>}"
	  unless ( defined $sortOrder->{position}
		&& ( "lexical numeric antiNumeric" =~ m/$sortOrder->{type}/ ) );

	if ( $sortOrder->{type} eq "numeric" ) {
		@matrix = (
			sort {
				@$a[ $sortOrder->{position} ] <=> @$b[ $sortOrder->{position} ]
			  } @matrix
		);
	}
	elsif ( $sortOrder->{type} eq "lexical" ) {
		@matrix = (
			sort {
				@$a[ $sortOrder->{position} ] cmp @$b[ $sortOrder->{position} ]
			  } @matrix
		);
	}
	elsif ( $sortOrder->{type} eq "antiNumeric" ) {
		@matrix = (
			sort {
				@$b[ $sortOrder->{position} ] <=> @$a[ $sortOrder->{position} ]
			  } @matrix
		);
	}

	my $i = $matchStart = 0;
	$value = $matrix[0][ $sortOrder->{position} ];

	if ( defined @$sortOrderArray[0] ) {

		for ( $i = 1 ; $i < @matrix ; $i++ ) {

			unless ( $value eq $matrix[$i][ $sortOrder->{position} ] ) {
				$value = $matrix[$i][ $sortOrder->{position} ];
				unless ( $i - $matchStart == 1 ) {
					splice(
						@matrix,
						$matchStart,
						0,
						&sortArrayBy(
							$sortOrderArray,
							splice( @matrix, $matchStart, $i - $matchStart ),
						)
					);
				}
				$matchStart = $i;
			}
		}
		unless ( $i - $matchStart == 1 ) {
			splice(
				@matrix,
				$matchStart,
				$i - $matchStart,
				&sortArrayBy(
					$sortOrderArray,
					splice( @matrix, $matchStart, $i - $matchStart ),
				)
			);
		}

	}
	unshift( @$sortOrderArray, $sortOrder );
	return @matrix;
}

1;
