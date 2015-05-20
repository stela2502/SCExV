#! /usr/bin/perl -w

#  Copyright (C) 2015-05-13 Stefan Lang

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

=head1 test_randomForestServer_send.pl

Sends data and recieves the return page from the server

To get further help use 'test_randomForestServer_send.pl -help' at the comman line.


=cut

use Getopt::Long;
use strict;
use warnings;

use FindBin;
my $plugin_path = "$FindBin::Bin";

my $VERSION = 'v1.0';


my ( $help, $debug, $database, $session_id, $path);

Getopt::Long::GetOptions(
	 "-session_id=s"    => \$session_id,
	 "-path=s"    => \$path,

	 "-help"             => \$help,
	 "-debug"            => \$debug
);

my $warn = '';
my $error = '';

unless ( defined $session_id) {
	$error .= "the cmd line switch -session_id is undefined!\n";
}
unless ( defined $path) {
	$error .= "the cmd line switch -path is undefined!\n";
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
 command line switches for test_randomForestServer_send.pl

   -session_id       :<please add some info!>
   -path       :<please add some info!>

   -help           :print this help
   -debug          :verbose output
   

"; 
}


my ( $task_description);

$task_description .= 'perl '.root->perl_include().' '.$plugin_path .'/test_randomForestServer_send.pl';
$task_description .= " -session_id $session_id" if (defined $session_id);
$task_description .= " -path $path" if (defined $path);



## Do whatever you want!

