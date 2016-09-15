package stefans_libs::GeneGroups;

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

use stefans_libs::flexible_data_structures::data_table;

use stefans_libs::GeneGroups::Set;
use stefans_libs::GeneGroups::R_table;

=for comment

This document is in Pod format.  To read this, use a Pod formatter,
like 'perldoc perlpod'.

=head1 NAME

stefans_libs::GeneGroups

=head1 DESCRIPTION

This is an data interface to store group definitions in a two dimensional dataset - 
works together with the PCR_analysis web server to offer graphic group creation.

=head2 depends on
=cut

=head1 METHODS

=head2 new

new returns a new object reference of the class stefans_libs::GeneGroups.

=cut

sub new {

	my ( $class, $hash ) = @_;

	my ($self);

	$self = {
		'group_file' => undef,
		'GS'         => {},
		'order'      => [],
		'data_file'  => ' ',
		'data'       => undef,
	};

	bless $self, $class if ( $class eq "stefans_libs::GeneGroups" );

	return $self;

}

sub clear {
	my ($self) = @_;
	my $class = ref($self);
	unlink( $self->{'group_file'} ) if ( -f $self->{'group_file'} );
	return $self->init();
}

sub init {
	my ($self) = @_;
	foreach (qw( group_file data_file data)) {
		$self->{$_} = undef;
	}
	$self->{'GS'}    = {};
	$self->{'order'} = [];
	return $self;
}

sub nGroup {
	my ($self) = @_;
	my $n = 0;
	map { $n += $_->nGroup() } $self->__Sets_in_order();
	return $n;
}

sub read_data {
	my ( $self, $filename, $use_data_table ) = @_;
	return $self->{'data'}
	  if ( $self->{'data_file'} eq $filename && defined $self->{'data_file'} );
	if ( -f $filename ) {
		$self->{'data_file'} = $filename;
		if ($use_data_table) {
			$self->{'data'} = stefans_libs::GeneGroups::R_table->new();
			my $data = data_table->new( { 'filename' => $filename } );
			$self->{'data'}->Add_2_Header( $data->{'header'} );
			$self->{'data'}->{'data'} = $data->{'data'};
		}
		else {
			$self->{'data'} =
			  stefans_libs::GeneGroups::R_table->new(
				{ 'filename' => $filename } );
		}

		return $self->{'data'};
	}
	return $self->{'data'}
	  if (
		ref( return $self->{'data'} ) eq 'stefans_libs::GeneGroups::R_table' );
	Carp::confess("I can not open the file '$filename'!\n$!\n");
}

sub read_old_grouping {
	my ( $self, $filename ) = @_;
	$self->{'old_grouping'} =
	  stefans_libs::GeneGroups::R_table->new( { 'filename' => $filename } );
	my $e = "Samples, red, green, blue, colorname";
	Carp::confess( "I need a file containing the columns $e; NOT "
		  . join( ", ", @{ $self->{'old_grouping'}->{'header'} } ) )
	  unless ( join( ", ", @{ $self->{'old_grouping'}->{'header'} } ) eq $e );
	return $self->{'old_grouping'};
}

sub export_R_exclude_samples {
	my ( $self, $rObj ) = @_;
	my $script =
"excludeGroups <- data.frame( cellName = rownames($rObj), groupID = rep.int(1, nrow($rObj)) )\n";
	foreach ( $self->__Sets_in_order() ) {
		$script .= $_->export_R_exclude_samples( $self, $rObj, 2 );
	}
	$script .=
"excludeSamples <- as.vector(excludeGroups\$cellName[excludeGroups\$groupID > 1 ])\n";
	return $script;
}

sub export_R {
	my ( $self, $rObj, $gname ) = @_;
	my $script =
"DaTaSeT <- $rObj\@data\nif ( $rObj\@wFACS ) {  DaTaSeT<- cbind( $rObj\@data, $rObj\@facs )}\n";
	my $nrObj = 'DaTaSeT';
	$script .=
"userGroups <- data.frame( cellName = rownames($nrObj), userInput = rep.int(1, nrow($nrObj)),"
	  . " groupID = rep.int(1, nrow($nrObj)) )\n";
	foreach ( $self->__Sets_in_order() ) {
		$script .= $_->export_R( $self, $nrObj, 2 );
	}
	$script .=
	    "gr <- userGroups <- checkGrouping( userGroups )\n"
	  . "$rObj\@samples[,'$gname'] <- gr\n";
	return $script;
}

sub write_R {
	my ( $self, $filename, $rObj, $gname ) = @_;
	open( OUT, ">$filename" )
	  or Carp::confess("I could not create the file '$filename'\n");
	print OUT $self->export_R( $rObj, $gname );
	close(OUT);
}

sub write_grouping {
	my ( $self, $filename ) = @_;
	open( OUT, ">$filename" )
	  or Carp::confess("I could not create the file '$filename'\n");
	$self->{'group_file'} = $filename;
	print OUT $self->AsString();
	close(OUT);
}

sub AsString {
	my ($self) = @_;
	my $string = "GeneGrouping 0.1\n";
	foreach ( $self->__Sets_in_order() ) {
		$string .= $_->AsString();
	}
	return $string;
}

sub __Sets_in_order {
	my $self = shift;
	return map { $self->{'GS'}->{$_} } @{ $self->{'order'} };
}

sub AddGroup {
	my ( $self, $geneX, $geneY, $x1, $x2, $y1, $y2 ) = @_;
	return $self->group4( $geneX, $geneY )->AddGroup( $x1, $x2, $y1, $y2 );
}

=head2 get_grouping8)

return a list of samples that would fall into the groups

=cut

sub group_samples {
	my ( $self, $geneA, $geneB ) = @_;
	return $self->group4( $geneA, $geneB )->group_samples( $self->{'data'} );
}

=head2 splice_expression_table($data_table)

This function separated the table ( columns == genes!!)
into the goups defined in this object.
Any group trying to re-group samples into a new group will fail!

It returns an array of data.table objects starting with the ungrouped data.
=cut

sub splice_expression_table {
	my ( $self, $data_table ) = @_;
	my ( @return_groups, $i, $return_not_grouped, $pg1, $pg2 );
	$i = 0;
	$data_table ||= $self->{'data'};
	Carp::confess("Sorry I do not have any data here!")
	  unless ( defined $data_table );
	$return_not_grouped = $data_table->copy();
	foreach my $set ( $self->__Sets_in_order() ) {
		for ( my $group = 1 ; $group <= $set->nGroup() ; $group++ )
		{    ## foreach group
			$return_groups[$i] = $data_table->_copy_without_data();
			($pg1) = $data_table->Header_Position( $set->{'g1'} );
			($pg2) = $data_table->Header_Position( $set->{'g2'} );
			Carp::confess(
"Gene $set->{'g1'} or $set->{'g2'} not defined in your test set!"
			) unless ( defined $pg1 && defined $pg2 );
			for (
				my $line = $return_not_grouped->Lines() - 1 ;
				$line >= 0 ;
				$line--
			  )
			{
				if (
					$set->match_2_group(
						@{ @{ $return_not_grouped->{'data'} }[$line] }[ $pg1,
						$pg2 ],
						$group
					)
				  )
				{
					push(
						@{ $return_groups[$i]->{'data'} },
						splice( @{ $return_not_grouped->{'data'} }, $line, 1 )
					);
				}

			}
			$return_groups[$i]->{'group_area'} = $set->group($group);
			$i++;
		}
	}
	return ( $return_not_grouped, @return_groups );
}

sub group4 {
	my ( $self, $geneX, $geneY ) = @_;
	my $key = "$geneX $geneY";
	unless ( defined $self->{'GS'}->{$key} ) {
		$self->{'GS'}->{$key} =
		  stefans_libs::GeneGroups::Set->new( $geneX, $geneY );
		push( @{ $self->{'order'} }, $key );
	}
	return $self->{'GS'}->{$key};
}

sub plot {
	my ( $self, $outfile, $geneA, $geneB ) = @_;
	if ( defined $self->{'old_grouping'} && $self->nGroup() == 0 ) {
		return $self->{'data'}->plotXY_fixed_Colors( $outfile, $geneA, $geneB,
			$self->{'old_grouping'} );
	}
	else {
		return $self->{'data'}->plotXY( $outfile, $geneA, $geneB, $self );
	}
}

sub read_grouping {
	my ( $self, $filename ) = @_;
	$self->{'group_file'} = '';    ## otherwise this file gets deleted!!
	$self->clear();
	open( IN, "<$filename" )
	  or Carp::confess("Read GeneGroup file '$filename' - impossible: $!\n");
	my ( $OK, $error, @line, $key );
	while (<IN>) {
		unless ( defined $OK ) {
			Carp::confess( 'Error: ' . "Wrong file format: $_" )
			  unless ( $_ eq "GeneGrouping 0.1\n" );
			$OK = 1;
			next;
		}
		chomp;
		@line = split( "\t", $_ );
		if ( $line[0] eq "markers" ) {
			$key = "$line[1] $line[2]";

		 #			Carp::confess( 'Error: ' . "Double definition of gene set $key\n" )
		 #			  if ( defined $self->{'GS'}->{$key} );
			$self->group4( $line[1], $line[2] );
			next;
		}
		Carp::confess( 'Error: ' . "No marker combination found in dataset!\n" )
		  unless ( defined $key );
		$self->{'GS'}->{$key}->processArray( \@line );
	}
	return $self;
}

1;
