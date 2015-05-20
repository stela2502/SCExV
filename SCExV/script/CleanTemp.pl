#! /usr/bin/perl -w

#  Copyright (C) 2014-08-29 Stefan Lang

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

=head1 CleanTemp.pl

Should be called by cron to clean the temp files on a regular basis (e.g all 20 min).

To get further help use 'CleanTemp.pl -help' at the comman line.

=cut

use Getopt::Long;
use strict;
use warnings;

use FindBin;
my $plugin_path = "$FindBin::Bin";

my $VERSION = 'v1.0';

my ( $help, $debug, $database, $check_path );

Getopt::Long::GetOptions(
	"-check_path=s" => \$check_path,

	"-help"  => \$help,
	"-debug" => \$debug
);

my $warn  = '';
my $error = '';

unless ( defined $check_path ) {
	$error .= "the cmd line switch -check_path is undefined!\n";
}

if ($help) {
	print helpString();
	exit;
}

if ( $error =~ m/\w/ ) {
	print helpString($error);
	exit;
}

sub helpString {
	my $errorMessage = shift;
	$errorMessage = ' ' unless ( defined $errorMessage );
	return "
 $errorMessage
 command line switches for CleanTemp.pl

   -check_path       :<please add some info!>

   -help           :print this help
   -debug          :verbose output
   

";
}
use stefans_libs::root;

die "Path $check_path not accessable: $!\n" unless ( -d $check_path );
my @tmp;

my $killable;
opendir( DIR, $check_path ) or die "could not open path $check_path\n$!\n";
$check_path .= "/" unless ( $check_path =~ m!/$! );
foreach ( grep(!/^\./, readdir(DIR)) ){
	if ( -d "$check_path$_" ) {
		$killable->{"$check_path$_"} = 1;
	}
}

close(DIR);

#print "\$exp = ".root->print_perl_var_def( $killable ).";\n";


my $master_level = scalar( split("/", $check_path)) +1;

open( SAVE, "find $check_path* -type f -amin -61 |" )
  or die "Could not fork!\n";

foreach my $save (<SAVE>) {
	@tmp = split("/",$save );
	pop(@tmp);
	while ( scalar(@tmp) > $master_level ) {
		pop(@tmp);
	}
	$killable->{join("/",@tmp)} = 0;
}
close(SAVE);

#print "\$exp = ".root->print_perl_var_def( $killable ).";\n";

foreach ( keys %$killable ) {
	print "rm -Rf $_\n" if ( $killable->{$_} );
	system ( "rm -Rf $_" ) if ( $killable->{$_} );
}

#Carp::confess(  "find $path/tmp/ -amin -61  | cut -d/ -f 2 | uniq > $path/new" );
#system ( "find $path/tmp/ -amin -61  | cut -d/ -f 2 | uniq > $path/new");
#system ( "find ./ -amin +61 | cut -d/ -f 2 | uniq | grep -vw -f$path/new | xargs rm -Rf {};");
#system ( 'rm -Rf '.__PACKAGE__->config->{'root'}."/tmp/*" );

