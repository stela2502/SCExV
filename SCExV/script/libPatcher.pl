#! /usr/bin/perl -w

#  Copyright (C) 2014-08-27 Stefan Lang

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

=head1 libPatcher.pl

This tool uses the new stefans_libs::file_readers::Patcher object to patch lib files.

To get further help use 'libPatcher.pl -help' at the comman line.

Usage e.g. like that:

perl libPatcher.pl -path ~/tmp/ -match "<tmpl_var comment-(\\w*)>" -replace "[% form.field." ".comment %]"

=cut

use Getopt::Long;
use strict;
use warnings;

use stefans_libs::file_readers::Patcher;
use stefans_libs::root;

use FindBin;
my $plugin_path = "$FindBin::Bin";

my $VERSION = 'v1.0';


my ( $help, $debug, $database, $path, $match, @replace);

Getopt::Long::GetOptions(
	 "-path=s"    => \$path,
	 "-match=s"    => \$match,
	 "-replace=s{,}"    => \@replace,

	 "-help"             => \$help,
	 "-debug"            => \$debug
);

my $warn = '';
my $error = '';

unless ( defined $path) {
	$error .= "the cmd line switch -path is undefined!\n";
}
unless ( defined $match) {
	$error .= "the cmd line switch -match is undefined!\n";
}
unless ( defined $replace[0]) {
	$error .= "the cmd line switch -replace is undefined!\n";
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
 command line switches for libPatcher.pl

   -path       :<please add some info!>
   -match       :<please add some info!>
   -replace       :<please add some info!> you can specify more entries to that

   -help           :print this help
   -debug          :verbose output
   

"; 
}


my ( $task_description);

$task_description .= 'perl '.root->perl_include().' '.$plugin_path .'/libPatcher.pl';
$task_description .= " -path $path" if (defined $path);
$task_description .= " -match $match" if (defined $match);
$task_description .= ' -replace '.join( ' ', @replace ) if ( defined $replace[0]);



## Do whatever you want!
my ( $OK, $replace );

if ( @replace == 1) {
	$replace = $replace[0];
}
else {
	$replace = \@replace;
}

&work_on_path($path);

sub work_on_path {
	my ( $path) = @_;
	opendir( Pair_PATH, $path )
      or die "I could not read from path '$path'\n$!\n";
    my @eintraege = readdir(Pair_PATH);
    closedir(Pair_PATH);
    foreach my $eintrag (@eintraege) {
    	next if ( $eintrag =~ m/^\./ );
        if ( -d "$path/$eintrag" ) {
            &work_on_path("$path/$eintrag");
        }
        my $obj = stefans_libs::file_readers::Patcher -> new( "$path/$eintrag" );
        $OK = 0;
		$OK = $obj -> replace_string( $match, $replace );
		print "Replaced at $OK position(s) of file $path/$eintrag\n";
		$obj -> write_file() if ( $OK );
    }
}
