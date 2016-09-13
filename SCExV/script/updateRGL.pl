#! /usr/bin/perl -w

=head1 LICENCE

  Copyright (C) 2016-09-13 Stefan Lang

  This program is free software; you can redistribute it 
  and/or modify it under the terms of the GNU General Public License 
  as published by the Free Software Foundation; 
  either version 3 of the License, or (at your option) any later version.

  This program is distributed in the hope that it will be useful, 
  but WITHOUT ANY WARRANTY; without even the implied warranty of 
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
  See the GNU General Public License for more details.

  You should have received a copy of the GNU General Public License 
  along with this program; if not, see <http://www.gnu.org/licenses/>.

=head1  SYNOPSIS

    updateRGL.pl


       -help           :print this help
       -debug          :verbose output
   
=head1 DESCRIPTION

  this script runs a initial rgl analysis and extracts the right CanvasMatrix4 and RGL class javascript objects. Subsequently updating the server files.

  To get further help use 'updateRGL.pl -help' at the comman line.

=cut

use Getopt::Long;
use Pod::Usage;

use HTpcrA::Model::java_splicer;
use strict;
use warnings;

use FindBin;
my $plugin_path = "$FindBin::Bin";

my $VERSION = 'v1.0';


my ( $help, $debug, $database);

Getopt::Long::GetOptions(

	 "-help"             => \$help,
	 "-debug"            => \$debug
);

my $warn = '';
my $error = '';



if ( $help ){
	print helpString( ) ;
	exit;
}

if ( $error =~ m/\w/ ){
	helpString($error ) ;
	exit;
}

sub helpString {
	my $errorMessage = shift;
	$errorMessage = ' ' unless ( defined $errorMessage); 
	print "$errorMessage.\n";
	pod2usage(q(-verbose) => 1);
}



my ( $task_description);

$task_description .= 'perl '.$plugin_path .'/updateRGL.pl';


open( Rscript, ">" . $plugin_path . "/t/data/oldRGL/createNew.R" );
print Rscript join(
	"\n",
	"options(rgl.useNULL=TRUE)", "library(rgl)",
	"with(iris, plot3d(Sepal.Length, Sepal.Width, Petal.Length,",
	"  type='s', col=as.numeric(Species)))",
"try(writeWebGL( width=470, height=470, dir = '$plugin_path/data/oldRGL/webGLNEW'),silent=silent)"
	,
);
close(Rscript);

system( "R CMD BATCH $plugin_path/t/data/oldRGL/createNew.R" );
my $obj = HTpcrA::Model::java_splicer->new();

my @values = $obj->classSplitter(  $plugin_path . "/data/oldRGL/webGLNEW/index.html" );
if ($values[0] =~m/CanvasMatrix4/) {
	open ( OUT, ">".$plugin_path."/root/scripts/CanvasMatrix4.js") or die $!;
	print OUT $values[0];
	close ( OUT );
}else {
	Carp::confess ( "I could not identify the CanvasMatrix4 object in the webgl output!")
}
if ($values[1] =~ m/rgltimerClass/) {
	open ( OUT, ">".$plugin_path."/root/scripts/rglClass.src.js") or die $!;
	print OUT $values[1];
	close ( OUT );
	
}else {
	Carp::confess ( "I could not identify the rglClass object in the webgl output!")
}

print "javascripot files updated!";



## Do whatever you want!

