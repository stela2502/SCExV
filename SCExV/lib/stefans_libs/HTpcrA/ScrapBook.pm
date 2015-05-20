package stefans_libs::HTpcrA::ScrapBook;

#  Copyright (C) 2014-10-21 Stefan Lang

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

stefans_libs::HTpcrA::ScrapBook

=head1 DESCRIPTION

An extremely easy interface to one HTML file including figures.

=head2 depends on


=cut

=head1 METHODS

=head2 new

new returns a new object reference of the class stefans_libs::HTpcrA::ScrapBook.

=cut

sub new {

	my ($class) = @_;

	my ($self);

	$self = {};

	bless $self, $class if ( $class eq "stefans_libs::HTpcrA::ScrapBook" );

	return $self;

}

sub AsString {
	my ( $self, $uri ) = @_;
	open( IN, "<$self->{'file'}" );
	my $str = join( "", <IN> );
	close(IN);
	return "No information stored" if ( $str eq "" );
	$str =~ s/src=(["'])/src=$1$uri/g;
	$uri.="Tables";
	$str =~ s/href=(["'])Tables/href=$1$uri/g;
	return $str;
}

sub init {
	my ( $self, $file ) = @_;
	Carp::confess("I need a filename at startup! NOT '$file'\n")
	  unless ( defined $file );
	my $filemap = root->filemap($file);
	$self->{'path'} = $filemap->{'path'};
	$self->{'file'} = $file;

	unless ( -f $file ) {
		mkdir( $filemap->{'path'} ) unless ( -f $filemap->{'path'} );
		mkdir( $filemap->{'path'} . "/Pictures" )
		  unless ( -f $filemap->{'path'} . "/Pictures" );
		system("touch $file");
	}

	return $self;
}

sub StoreFile {
	my ( $self, $file, $type ) = @_;
	my $filemap = root->filemap($file);
	$type ||= "Pictures";
	my $add     = 1;
	mkdir ( $self->{'path'} . "/$type") unless ( -d $self->{'path'} . "/$type" );
	while ( 
		-f $self->{'path'} . "/$type/$add" . "_" . $filemap->{'filename'} )
	{
		$add++;
	}
	system( "cp  $filemap->{'total'} "
		  . $self->{'path'}
		  . "/$type/$add" . "_"
		  . $filemap->{'filename'} );
	return $self->{'path'} . "/$type/$add" . "_" . $filemap->{'filename'};
}

sub Add {
	my ( $self, $text, $file ) = @_;
	my $str;
	if ( -f $file ) {
		unless ( $file =~ m!^$self->{'path'}/?Pictures! ) {
			$file = $self->StoreFile($file);
		}
	}
	if ( defined $file ) {
		Carp::confess("Internal error: Picture file $file could not be found!")
		  if ( !-f $file && !-f $self->{'path'} . "/" . $file );
		$file =~ s/$self->{'path'}//;
		$file =~ s!^/!!;
		$str =
		    "\n<figure>\n"
		  . "\t<img src=\"$file\" width=\"50%\">\n"
		  . "\t<figcaption>$text</figcaption>\n"
		  . "</figure> \n\n";
	}
	else {
		$str = "\n<p>$text</p>\n\n";
	}
	open( OUT, ">>$self->{'file'}" );
	print OUT $str;
	close(OUT);
}

sub Add_Table {
	my ( $self, $text, $file ) = @_;
	my $str;
	if ( -f $file ) {
		$file = $self->StoreFile($file, 'Tables');
	}
	if ( defined $file ) {
		Carp::confess("Internal error: Picture file $file could not be found!")
		  if ( !-f $file && !-f $self->{'path'} . "/" . $file );
		$file =~ s/$self->{'path'}//;
		$file =~ s!^/!!;
		if ( $text =~ m/TABLE_FILE/ ){
			$text =~ s/TABLE_FILE/$file/;
			$str = $text;
		}
		else {
			my $dt = data_table->new({'filename' => $file });
			$str = $dt -> AsHTML()."\n<p>$text</p>\n\n";
		}
	}
	else {
		$str = "\n<p>$text</p>\n\n";
	}
	open( OUT, ">>$self->{'file'}" );
	print OUT $str;
	close(OUT);
}

1;
