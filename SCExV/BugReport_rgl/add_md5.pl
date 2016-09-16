#! /usr/bin/perl -w

#  Copyright (C) 2016-01-12 Stefan Lang

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

=head1 add_md5.pl

Add the md5 sum over each line to a text file.

To get further help use 'add_md5.pl -help' at the comman line.

=cut

use Getopt::Long;
use strict;
use warnings;

use Digest::MD5 qw(md5_hex);

use FindBin;
my $plugin_path = "$FindBin::Bin";

my $VERSION = 'v1.0';


my ( $help, $debug, $database, $infile, $outfile);

Getopt::Long::GetOptions(
	 "-infile=s"    => \$infile,
	 "-outfile=s"    => \$outfile,

	 "-help"             => \$help,
	 "-debug"            => \$debug
);

my $warn = '';
my $error = '';

unless ( defined $infile) {
	$error .= "the cmd line switch -infile is undefined!\n";
}
unless ( defined $outfile) {
	$error .= "the cmd line switch -outfile is undefined!\n";
}


if ( $help ){
	print helpString( ) ;
	exit;
}

if ( $error =~ m/\w/ ){
	print helpString($error ) ;
	exit;
}

sub helpString {
	my $errorMessage = shift;
	$errorMessage = ' ' unless ( defined $errorMessage); 
 	return "
 $errorMessage
 command line switches for add_md5.pl

   -infile       :<please add some info!>
   -outfile       :<please add some info!>

   -help           :print this help
   -debug          :verbose output
   

"; 
}


my ( $task_description);

$task_description .= 'perl'. $plugin_path .'/add_md5.pl';
$task_description .= " -infile $infile" if (defined $infile);
$task_description .= " -outfile $outfile" if (defined $outfile);


open ( LOG , ">$outfile.log") or die $!;
print LOG $task_description."\n";
close ( LOG );


## Do whatever you want!

open ( IN, "<$infile" ) or die $!;
open ( OUT , ">$outfile" ) or die $!;
while ( <IN> ) {
	print OUT md5_hex($_).": $_";
}
close (IN);
close (OUT);
print "Done\n";

