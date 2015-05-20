package root;

use Carp;

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
use Date::Simple;
use Statistics::Descriptive;

eval{
#use DBD::DB2::Constants;
#use DBD::DB2;
};

=for comment

This document is in Pod format.  To read this, use a Pod formatter,
like "perldoc perlpod".

=head1 NAME

stefans_libs::root

=head1 DESCRIPTION

root is a small collection of methods that are used in many libary parts of my programming work.

The methods are:
L<FileError|/"FileError">,
L<Today|"Today">,
L<Max|"Max">,
L<Min|"Min">,
L<GetMatchingFeaturesOfFlatFile|"GetMatchingFeaturesOfFlatFile">,
L<getDBH|"getDBH">,
L<getStandardDeviation|"getStandardDeviation">,
L<getPureSequenceName|"getPureSequenceName">,
L<median|"median">,
L<mittelwert|"mittelwert"> and
L<ParseHMM_filename|"ParseHMM_filename">.

=cut

=head1 METHODS

=head2 new

The method new returns a root object. No Variables are needed.

=cut

sub new {
	my ($class) = @_;

	my ($self);
	$self = {};

	bless( $self, $class ) if ( $class eq "root" );

	return $self;
}

=head2 FileError

FileError returns the string "Konnte File $file nicht öffnen\n".

The Filename has to be provided as first variable.

=cut

sub FileOpenError {
	my ( $self, $file ) = @_;
	return "Konnte File $file nicht oeffnen\n";
}

sub get_temp_dir{
	return "/home/stefan/temp/simply_removeable/";
}

sub FileError {
	my ( $self, $file ) = @_;
	return $self->FileOpenError($file);
}

sub FileWriteError {
	my ( $self, $file ) = @_;
	return "Konnte File $file nicht anlegen\n";
}

sub identifyCaller {
	my ( $class, $function ) = @_;
	my $i = 0;
	my $result;
	while (1) {
		my ( $package, $filename, $line, $subroutine ) = caller( $i++ );
		if ( defined($package) && ( $package ne "main" ) ) {
			$result = $subroutine;
		}
		else {
			last;
		}
	}
	print "$class $function was called by $result!\n";
}

=head2 Today

Today somply returns a Data::Simple object.

I<return Date::Simple->new();

L<Date::Simple>
    
=cut

sub Today {
	return Date::Simple->new();
}

=head2 Max

Returns the maximum integer value of the array of variables given.

=cut

sub Max {
	my ( $self, @list ) = @_;
	my $max = 0;
	for ( my $i = 0 ; $i < @list ; $i++ ) {
		$max = $list[$i] if ( $max < $list[$i] && defined $list[$i] );
	}

	#    @list = sort numeric @list;
	#    my $max = $list[@list-1];
	return $max;
}

=head2 Min

Returns the minimum integer value of the array of variables given.

=cut

sub Min {
	my ( $self, @list ) = @_;
	my $min = 1e999;
	for ( my $i = 0 ; $i < @list ; $i++ ) {
		$min = $list[$i] if ( $min > $list[$i] && defined $list[$i] );
	}

	#    @list = sort numeric @list;
	#    my $min = $list[0];
	return $min;
}

=head2 ParseHMM_filename

HMM data files are formated like this:

path2file/Antibody-Celltype-Organism-DesignID-IterationNr.gff

ParseHMM_filename uses only the filename and returns a hash consisting of
Organism, CellType, AB, Iteration and designID.

=head2 filemap

This function sepqrates a filename into 
'filename_base' = the part of the filename before any '.'
'filename_core' = everything from the filename apart the filename_ext
'filename_ext'  = the file extension (after the last '.')
'path'          = all path information of the file string

=cut
sub filemap{
	shift->parse_path(@_);
}
sub parse_path{
	my ( $self, $filename ) = @_;
	my @temp = split("/",$filename );
	my $ret = {};
	$ret -> {'total'} = $filename;
	$ret -> {'filename'} =pop(@temp);
	$temp[0] = "./" unless ( defined $temp[0]);
	$ret -> {'path'} = join("/", @temp);
	@temp = split(/\./, $ret -> {'filename'});
	$ret -> {'filename_base'} = $temp[0];
	$ret -> {'filename_ext'} = pop(@temp);
	if ( @temp == 0 ) {
		$ret -> {'filename_core'} = $ret -> {'filename_ext'};
		$ret -> {'filename_ext'} = '';
	}
	else {
		$ret -> {'filename_core'} = join( '.',@temp);
	}
	return $ret;
}

sub ParseHMM_filename {
	my ( $self, $filename, $what ) = @_;
	my ( @temp, $data, $temp );

	print "ParseHMM_filename $filename\n";
	$what = "default" unless ( defined $what );

	return undef unless ( defined $filename );
	@temp = split( "/", $filename );
	$data->{filename} = $temp[ @temp - 1 ];
	@temp = split( "-", $temp[ @temp - 1 ] );

	$data->{AB} = $temp[0];    ## immer

	#    $temp             = $temp[1];
	$data->{CellType} = $temp[1];
	$data->{Organism} = $temp[2];
	$data->{designID} = $1
	  if ( $filename =~ m/(\d\d\d\d-\d\d-\d\d_RZPD\d\d\d\d_MM\d_ChIP)/ );
	$data->{Iteration} = $1 if ( $filename =~ m/IterationNr\.?(\d+)/ );

   #print "root ParseHMM_filename iteration = $data->{Iteration} ($filename)\n";
	@temp = split( "_", $data->{CellType} );
	$data->{CellType} = join( " ", @temp );

	#    $data->{AB} = "$data->{AB}" if ( defined $temp );

	#    $data->{Organism} = "Mus musculus";

	#foreach $temp ( keys %$data ) {
	#    print "$temp -> $data->{$temp}\n";
	#}

	return $data->{Organism}, $data->{CellType}, $data->{AB}, $data->{Iteration}
	  if ( $what eq "array" );
	return $data;
}

=head2 mittelwert

Returns the mean from the array of numbers given by the reference(!) to that array.

The array values are not changed.

=cut

sub mittelwert {
	my ( $self, $Werte ) = @_;

	my ( $i, $sum, $wert );
	$i   = 0;
	$sum = 0;

	foreach $wert (@$Werte) {
		next unless ( defined $wert );
		$sum = $sum + $wert;
		$i++;
	}

	#    print "Summe: $gesammt\nn: $i\n";
	return ( $sum / $i ), $i unless ( $i == 0 );
	return "No Values", 0;
}

sub mean {
	my ( $self, $Werte ) = @_;
	my ( $mean, $anzahl ) = root::mittelwert( "root", $Werte );
	return $mean;
}

sub quantilCutoff {
	my ( $self, $data, $quantile ) = @_;
	if ( lc($data) =~ m/hash/ ) {
		my @temp = ( values %$data );
		return $self->quantilCutoff( $data, $quantile );
	}
	my ( @sorted, $rank );
	@sorted = sort numeric @$data;
	$rank = int( ( $quantile * (@$data) ) / 100 );

	#	$rank = @$data - $rank;
	my $count = @$data;
	print
"max value = $sorted[0] min value = $sorted[$count-1] percentil $quantile = $sorted[$rank]\n";
	return $sorted[$rank];
}

=head2 median

Returns the median from the array of numbers given by the reference(!) to that array.

The array values are not changed.

=cut

sub median {
	my ( $self, $Werte ) = @_;

	if ( lc($Werte) =~ m/hash/ ) {
		 return $self->median( values %$Werte );
	}
	my @sorted = sort numeric @$Werte;
	if ( @sorted % 2 == 0 ) {    ## gerade anzahl an werten!
		return $sorted[ @sorted / 2 ];
	}
	else {
		@sorted =
		  ( $sorted[ int( @sorted / 2 ) ], $sorted[ int( @sorted / 2 + 1 ) ] );
		@sorted = $self->mittelwert( \@sorted );
		return $sorted[0];
	}
}

=head2 MAD

the function calculated the median absolute deviation from an array of values.

=cut

sub MAD {
	my ( $self, $values, $median ) = @_;
	my ( $MAD, @MAD_values );
	$median = $self->median($values) unless ( defined $median );
	foreach my $val (@$values) {
		push( @MAD_values, ( ( $val - $median )**2 )**0.5 );
	}
	return $self->median( \@MAD_values );
}

=head2 getPureSequenceName

getPureSequenceName splitts up a file string in the format 
'/path2file/filename.suffix'
into its parts.
getPureSequenceName returns a hash consisting of {path} = /path2file; {filename} = filename.suffix 
and {MySQL_entry} = filename.

=cut

sub getPureSequenceName {

	my ( $self, $GBKfile ) = @_;
	my ( @fileRep, $sequenceInfo, $pureInfo, $temp );

	@fileRep = split( "/", $GBKfile );
	$sequenceInfo = pop @fileRep;
	
	my $path = join( "/", @fileRep );

	@fileRep = split( /\./, $sequenceInfo );
	$pureInfo = "$fileRep[0]";

	my $return;
	$return->{MySQL_entry}  = $pureInfo;
	$return->{filename}     = $sequenceInfo;
	$return->{path}         = $path;
	$return->{fileLocation} = $GBKfile;
	return $return;

#    my %return = { MySQL_entry => $pureInfo , filename => $sequenceInfo, path => $path};
#    return \%return;
}

=sub whisker_data ( [values] )

This function will return an hash containing the values 
'median', 'lower', 'upper', 'min' and 'max', that can be plotted as whisker plot.

=cut

sub whisker_data {
	my ( $self, $data ) = @_;
	Carp::confess(
		"Sorry, but I (root->whisker_data) expect to get a array of values!")
	  unless ( ref($data) eq "ARRAY" );
	my $stat = Statistics::Descriptive::Full->new();
	$stat->add_data(@$data);
	return {
			'median' => $stat->quantile(2),
			'lower'  => $stat->quantile(1),
			'upper'  => $stat->quantile(3),
			'min' => $stat->quantile(0),
			'max' => $stat->quantile(4),
		};
}

=head2 getStandardDeviation

Returns three variables, $mean ,$n and  $StdAbw representing the mean, varianze and standard deviation of the 
array of numbers given by the reference(!) to that array. The array is not changed.

=cut

sub getStandardDeviation {
	my ( $self, $Werte ) = @_;

	my ( $sum_of_Differences_from_mittelwert,
		$Varianz, $StandartAbweichung, $mean, $anzahl, @temp );

	if ( $Werte =~ m/HASH/ ) {
		warn "getStandardDeviation got a hash!\n";
		foreach my $temp ( values %$Werte ) {
			push( @temp, $temp );
		}
		return $self->getStandardDeviation( \@temp );
	}

	( $mean, $anzahl ) = $self->mittelwert($Werte);
	
	return $mean, $anzahl, "Undef" if ( $anzahl == 1 );
	#    print "root->mittelwert returned $mean, $anzahl\n";
	$sum_of_Differences_from_mittelwert = 0;

	foreach my $wert (@$Werte) {
		next unless ( defined $wert );
		$sum_of_Differences_from_mittelwert =
		  $sum_of_Differences_from_mittelwert + ( $wert - $mean )**2;
	}
	
	$Varianz = ( $sum_of_Differences_from_mittelwert / ( $anzahl - 1 ) );
	$StandartAbweichung = sqrt($Varianz);
	return $mean, $anzahl, $StandartAbweichung;
}


=head2 getDBH

getDBH is a possible security risk, as the mysql user data is stored here.
It returns a MySQL database handle with the 
/ DBI->connect( "DBI:$driver:$dbname:$host", $dbuser, $dbPW ) / method from
L<::DBI>. 

The perllib perl-DBI and possibly perl-DBD-mysql have to be installed for this function.

=cut

sub __dbh_file{
	my ( $self ) = @_;
	return &__dbh_path()."perl_config.xml";
}

sub __dbh_path{
	my ( $self ) = @_;
return "/private/workarea/shared/geneexpress/";
}


=head2 FlatFileSplitter

Depricated to gone.

=cut

#sub FlatFileSplitter {
#  my ( $self, $flatfile) = @_;
#
#  my (@return, $ID, $AC, @temp, $data , $line, @feature);
#
#  open (DATA,"<$flatfile") or die "Konnte das flat file $flatfile nicht öffnen!\n";
#
#  while (<DATA>){
#     if ( $_ =~ m/(^\/\/$)/){
#        if ( defined @feature ){
#           my ($return, @data);
#           foreach $line (@feature){
#               push (@data,$line);
#           }
#           push (@data,"//\n");
##           print "FlatFileSplitter:\n",join("",@data);
#           $return->{flatFile} = join("",@data); #\@data;
#           $return->{ID} = $ID;
#           $return->{AC} = $AC;
#           push(@return,$return);
#           $AC = $ID = undef;
#           @feature  = undef;
#        }
#        next;
#    }
#    if ( $_ =~ m/^AC/){
#       @temp = split (" ", $_);
#       $AC = $temp[1];
#    }
#    if ( $_ =~ m/^ID/){
#       @temp = split (" ", $_);
#       $ID = $temp[1];
#    }
#    push(@feature,$_);
#  }
#
#  return \@return;
#}

=head2 GetMatchingFeaturesOfFlatFile

This method is a potent biological flatfile search algorithm
if the flatfile has the line I<//> als entry end. 

The method is called by root->GetMatchingFeaturesOfFlatFile($flatfile, $searchString ).

The method returns a reference to an array of text formated
lines of the flatfile where a searchString matches to the entry and
a reference to an array where all feature enries starting with /^ID/ are stored.

=cut

sub GetMatchingFeaturesOfFlatFile {
	my ( $self, $flatfile, $searchString ) = @_;

	my ( @return, $match_Mus_musculus, @feature, $i, $line, @temp, @ID, $temp );

	open( DATA, "<$flatfile" )
	  or die "Konnte das UniProt flat file $flatfile nicht öffnen!\n";
	$i = 0;

	while (<DATA>) {
		if ( $_ =~ m/(^\/\/$)/ ) {
			if ( $match_Mus_musculus eq $searchString ) {
				foreach $line (@feature) {
					push( @return, $line );
				}
				push( @return, "//\n" );
			}
			$match_Mus_musculus = "none";
			@feature            = undef;
			next;
		}
		if ( $_ =~ m/^ID/ ) {

			#       @temp = split(" *",$_);
			$temp = $_;
			chop $temp;
		}

		if ( $_ =~ m/($searchString)/ ) {
			$match_Mus_musculus = $1;
			push( @ID, $temp );
			$i++;
		}

		push( @feature, $_ );
	}
	## cleanup:

	if ( $match_Mus_musculus eq $searchString ) {
		foreach $line (@feature) {
			push( @return, $line );
		}
		push( @return, "//\n" );
	}

	print
	  "GetMatchingFeaturesOfFlatFile search string $searchString not found\n"
	  if ( $i == 0 );
	return undef if ( $i == 0 );
	return \@return, \@ID;

}

=head2 FlatFileSpliter

=head3 atributes

[0]: position of the flatfile 

=head3 return values

A reference to a array with the structure [ [ $featureLines ] ];

=cut

sub FlatFileSpliter {
	my ( $self, $flatfile ) = @_;

	my ( $i, @features, $featureRef, @temp );

	open( DATA, "<$flatfile" )
	  or die "Konnte das UniProt flat file $flatfile nicht öffnen!\n";
	$i = 0;

	print "root opened flat file $flatfile\n";

	$featureRef = \@temp;

	while (<DATA>) {
		chomp $_;
		push( @$featureRef, $_ );

		if ( $_ =~ m/(^\/\/)/ ) {
			$features[ $i++ ] = $featureRef;
			my @temp;
			$featureRef = \@temp;
		}
	}
	close(DATA);
	print "root found $i entries\n";
	return \@features;
}

sub print_perl_var_def {
	my ( $self, $var ) = @_;
	my $return = '';
	if ( ref($var) eq "HASH" ) {
		$return = "{\n";
		foreach my $name ( keys %$var ) {
			$return .= "  '$name' => "
			  . $self->print_perl_var_def( $var->{$name} ) . ",\n";
		}
		chop($return);
		chop($return);
		$return .= "\n}";
	}
	elsif ( ref($var) eq "ARRAY" ) {
		$return = "[ ";
		foreach (@$var) {
			$return .= $self->print_perl_var_def($_) . ", ";
		}
		chop($return);
		chop($return);
		$return .= " ]";
	}
	else {
		unless ( length($var) > 0 ){
			$return .= 'undef';
		}
		else {
			$return .= "'$var'";
		}
	}
	return $return;
}

sub CreatePath {
	my ( $self, $path ) = @_;
	if ( defined $path ) {
		my ( @temp, @path );
		@temp = split( "/", $path );

		for ( my $i = 0 ; $i < @temp ; $i++ ) {
			$path[$i] = $temp[$i];
			mkdir( join( "/", @path ) ) unless ( -d join( "/", @path ) );
		}
		return 1;
	}
	return $path;
}

sub numeric {
	return $a <=> $b;
}

sub print_hashEntries {
	my ( $hash, $maxDepth, $topMessage ) = @_;
	print &get_hashEntries_as_string( $hash, $maxDepth, $topMessage );
}

sub Latex_Label {
	my ( $self, $str ) = @_;
	$str =~ s/_//g;
	$str =~ s/\\//g;
	return $str;
}

sub get_hashEntries_as_string {
	my ( $hash, $maxDepth, $topMessage ) = @_;

	#	print "output of hashes deactivated in root::print_hashEntries()\n";
	#	return 1;
	my $string = '';
	if ( defined $topMessage ) {
		$string .= "$topMessage\n";
	}
	else {
		$string .= "DEBUG entries of the data structure $hash:\n";

	}

	#warn "production state - no further info\n";
	#return 1;
	if ( $hash =~ m/ARRAY/ ) {
		my $i = 0;
		foreach my $value (@$hash) {
			$string .=
			  printEntry( "List entry $i", $value, 1, $maxDepth, $string );
			$i++;
		}
	}
	elsif ( $hash =~ m/HASH/ ) {
		my $key;
		foreach $key ( sort keys %$hash ) {
			$string .= printEntry( $key, $hash->{$key}, 1, $maxDepth, $string );
		}
	}

	return $string;
}

sub perl_include {
	return
" -I /storage/www/Genexpress/lib/ -I /home/stefan/LibsNewStructure/lib/ ";
}

sub printEntry {
	my ( $key, $value, $i, $maxDepth ) = @_;

	my $max    = 10;
	my $string = '';
	my ( $printableString, $maxStrLength );
	$maxStrLength = 50;

	if ( defined $value ) {
		for ( $a = $i ; $a > 0 ; $a-- ) {
			$string .= "\t";
		}
		$printableString = $value;
		if ( length($value) > $maxStrLength ) {
			$printableString = substr( $value, 0, $maxStrLength );
			$printableString = "$printableString ...";
		}
		$string .= "$key\t$printableString\n";
	}
	else {
		for ( $a = $i ; $a > 0 ; $a-- ) {
			$string .= "\t";
		}
		$printableString = $key;
		if ( length($printableString) > $maxStrLength ) {
			$printableString = substr( $key, 0, $maxStrLength );
			$printableString = "$printableString ...";
		}
		$string .= "$printableString\n";
	}
	return $string if ( $maxDepth == $i );
	if ( defined $value ) {
		if ( ref($value) eq "ARRAY" ) {
			$max = 20;
			foreach my $value1 (@$value) {
				$string .=
				  printEntry( $value1, undef, $i + 1, $maxDepth, $string )
				  if ( defined $value1 );
				last if ( $max-- == 0 );
			}
		}
		elsif (  $value =~ m/HASH/ ) {
			$max = 20;
			while ( my ( $key1, $value1 ) = each %$value ) {
				$string .=
				  printEntry( $key1, $value1, $i + 1, $maxDepth, $string );
				last if ( $max-- == 0 );
			}
		}
	}
	if ( defined $key ) {
		if ( ref($key) eq "ARRAY" ) {
			$max = 20;
			foreach my $value1 (@$key) {
				$string .=
				  printEntry( $value1, undef, $i + 1, $maxDepth, $string );
				last if ( $max-- == 0 );
			}
		}
		elsif ( ref($key) eq "HASH" ) {
			$max = 20;
			while ( my ( $key1, $value1 ) = each %$key ) {
				$string .=
				  printEntry( $key1, $value1, $i + 1, $maxDepth, $string );
				last if ( $max-- == 0 );
			}
		}
	}
	return $string;
}

1;
