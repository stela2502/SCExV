package stefans_libs::file_readers::Patcher;
#  Copyright (C) 2014-08-20 Stefan Lang

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

stefans_libs::file_readers::Patcher

=head1 DESCRIPTION

This object helps to patch files - extremely simple

=head2 depends on


=cut


=head1 METHODS

=head2 new

new returns a new object reference of the class stefans_libs::file_readers::Patcher.

=cut

sub new{

	my ( $class, $filename ) = @_;

	my ( $self );

	$self = {
		'str_rep' => '',
		'data' => [],
		'filename' => '',
  	};

  	bless $self, $class  if ( $class eq "stefans_libs::file_readers::Patcher" );
	$self->read_file( $filename ) if ( -f $filename);
  	return $self;

}

sub replace_string {
	my ( $self, $target, $replacement ) = @_;
	my $replacements;
	if ( ref($replacement) eq "ARRAY" ){
		$replacements = $self->{'str_rep'} =~ s/$target/@$replacement[0]$1@$replacement[1]/g;
	}
	else {
		$replacements = $self->{'str_rep'} =~ s/$target/$replacement/g;
	}
	
	if ( $replacements ){
		$self->{'data'} = [split("\n", $self->{'str_rep'} )];
	}
	return $replacements;
}

sub replace_inLine {
	my ( $self, $target, $replacement ) = @_;
	my $replacements = 0;
	for ( my $i = 0; $i < @{$self->{'data'}} ; $i ++ ){
		$replacements +=  @{$self->{'data'}}[$i] =~ s/$target/$replacement/g;
	}
	
	if ( $replacements ){
		$self->{'str_rep'} = join("\n", @{$self->{'data'}});
	}
	return $replacements;
}

sub read_file{
	my ( $self, $filename ) =@_;
	if ( -f $filename ) {
		open ( IN, "<$filename" );
		while ( <IN> ){
			$self->{'str_rep'} .= $_;
			chomp($_);
			push ( @{$self->{'data'}}, $_);
		}
		close ( IN );
		$self->{'filename'} = $filename;
	}
}

sub write_file {
	my ( $self ) = @_;
	$self->check_obj();
	open ( OUT, ">$self->{'filename'}") or die $!;
	print OUT $self->{'str_rep'};
	close ( OUT );
	return 1;
}

sub check_obj {
	my ( $self ) = @_;
	unless ( defined $self->{'filename'} ) {
		Carp::confess ( "Sorry I can not wirte to a undefined file - please read in a file before you patch and write one!")
	}
}

1;
