package stefans_libs::file_readers::PCR_Raw_Tables;

#  Copyright (C) 2014-05-15 Stefan Lang

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
use warnings;
use POSIX;
use stefans_libs::flexible_data_structures::data_table;
use base 'data_table';

=head1 General description

This lib reads the PCR csv files, calculated some tests and exports the dfiles as data tables.

=cut

sub new {

	my ( $class, $hash ) = @_;

	my ($self);
	unless ( ref($hash) eq "HASH" ) {
		$hash = { 'debug' => $hash };
	}
	$self = {
		'debug'           => $hash->{'debug'},
		'arraySorter'     => arraySorter->new(),
		'sample_postfix'  => '',
		'header_position' => {},
		'default_value'   => [],
		'header'          => [],
		'data'            => [],
		'index'           => {},
		'last_warning'    => '',
		'subsets'         => {}
	};
	bless $self, "stefans_libs::file_readers::PCR_Raw_Tables";
#	$self->Add_2_Header(
#		[
#			'ID',                'Sample-Name',
#			'Sample-Type',       'Sample-rConc',
#			'FAM-MGB-Name',      'FAM-MGB-Type',
#			'FAM-MGB-Reference', 'Ct-Value',
#			'Ct-Quality',        'Ct-Call',
#			'Threshold',         'Value',
#			'Quality',           'Call',
#		]
#	);
	$self->string_separator();    ##init
	$self->line_separator();      ##init

	$self->init_rows( $hash->{'nrow'} )     if ( defined $hash->{'nrow'} );
	$self->read_file( $hash->{'filename'} ) if ( defined $hash->{'filename'} );
	return $self;
}

sub Sample_Postfix {
	my ( $self, $sample_postfix ) = @_;

	#Carp::confess ( "I got the postfix '$sample_postfix'\n");
	$self->{'sample_postfix'} = $sample_postfix;
	return $self;
}

sub After_Data_read {
	my ($self) = @_;
	$self->{'data_table'}         = data_table->new();
	$self->{'control_data_table'} = data_table->new({'debug'=>1});
	my ( $dataset, $last_name, $max, $add );
	$max       = 0;
	$last_name = '';
	foreach ( @{ $self->GetAll_AsHashArrayRef() } ) {
		unless ( $last_name eq $_->{'Sample-Name'} ) {
			if ( lc($last_name) =~ m/nort/ ) {
				unless ( defined @{ $self->{'data_table'}->{'header'} }[0] ) {
					$self->{'data_table'}
					  ->Add_2_Header( [ 'Sample-Name', sort keys %$dataset ] );
					$self->{'control_data_table'}
					  ->Add_2_Header( [ 'Sample-Name', sort keys %$dataset ] );
				}
				$dataset->{'Sample-Name'} .= $self->{'sample_postfix'};
				$self->{'control_data_table'}->AddDataset($dataset);
			}
			elsif ( length($last_name) > 0 ) {
				unless ( defined @{ $self->{'data_table'}->{'header'} }[0] ) {
					$self->{'data_table'}
					  ->Add_2_Header( [ 'Sample-Name', sort keys %$dataset ] );
					$self->{'control_data_table'}
					  ->Add_2_Header( [ 'Sample-Name', sort keys %$dataset ] );
				}
				$dataset->{'Sample-Name'} .= $self->{'sample_postfix'};
				$self->{'data_table'}->AddDataset($dataset);
			}
			$last_name = $_->{'Sample-Name'};
			$dataset = { 'Sample-Name' => $_->{'Sample-Name'} };
		}
		$max = $_->{'Ct-Value'}
		  if ( $_->{'Ct-Value'} > $max && $_->{'Ct-Value'} != 999 );
		$add = 1;
		while ( defined  $dataset->{ $_->{'FAM-MGB-Name'} } ){
			$_->{'FAM-MGB-Name'} =~ s/\.\d+$//;
			$_->{'FAM-MGB-Name'} .= ".".$add++;
		}
		$dataset->{ $_->{'FAM-MGB-Name'} } = $_->{'Ct-Value'};
	}
	if ( $last_name =~ m/noRT/ ) {
		$dataset->{'Sample-Name'} .= $self->{'sample_postfix'};
		$self->{'control_data_table'}->AddDataset($dataset);
	}
	elsif ( length($last_name)>0 ) {
		$dataset->{'Sample-Name'} .= $self->{'sample_postfix'};
		$self->{'data_table'}->AddDataset($dataset);
	}
	$max = ceil($max);
	for ( @{ $self->{'data_table'}->{'data'} } ) {
		for (@$_) { s/999/$max/g }
	}
	for ( @{ $self->{'control_data_table'}->{'data'} } ) {
		for (@$_) { s/999/$max/g }
	}
	return 1;
}

sub read_file {
	my ( $self, $filename, $lines ) = @_;
	return undef unless ( -f $filename );
	if ( $self->Lines > 0 ) {
		$self = ref($self)->new();
	}
	$self->{'read_filename'} = $filename;
	$self->{'data'}          = [];
	$self->string_separator();     ##init
	$self->line_separator(',');    ##init
	my ($last, @description, @line, $value, $temp, $i );
	open( IN, "<$filename" )
	  or die ref($self)
	  . "::read_file -> could not open file '$filename'\n$!\n";

	my $OK = $i = 0;
	
	foreach (<IN>) {
		$_ =~ s/\r/\n/;
		chomp($_);
		unless ($OK){
			$OK = 1 if ( substr($_,0,3) eq "ID," );
		}
		unless ( $OK ){
			$last = $_;
			next;
		}
		if ( $OK == 1 ){
			my @a = split(",",$last);
			my @b = split(",",$_);
			for ( my $i =0; $i < @a; $i ++ ){
				$a[$i] = $a[$i].'-'.$b[$i];
			}
			$self->Add_2_Header( \@a );
			$OK++;
			next;
		}
		push( @{ $self->{'data'} }, [split(",",$_)]);
		$OK++;
	}
	Carp::confess(">I have not found the starting line (^ID,) in file $filename\n")
	  unless ( @{ $self->{'data'} } > 0 );
	$self->line_separator("\t");
	$self->After_Data_read();
	return $self;
}

## two function you can use to modify the reading of the data.

sub pre_process_array {
	my ( $self, $data ) = @_;
	##you could remove some header entries, that are not really tagged as such...
	return 1;
}


1;
