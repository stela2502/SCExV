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
	"-help"  => \$help,
	"-debug" => \$debug
);

my $warn  = '';
my $error = '';



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

   -help           :print this help
   -debug          :verbose output
   
   The script will read the file/etc/SCExV/tmpPaths.txt and 
   remove all folders that have not been changed for over an hour.
   
";
}
use stefans_libs::root;

open ( PATHS, "</etc/SCExV/tmp_path.txt" ) or die "No accessible tmp path config file '/etc/SCExV/tmp_path.txt'\n$!\n"; 

my (@tmp, $killable, $master_level);

while ( <PATHS> ) {
	chomp();
	$check_path = $_;
	unless ( -d $check_path ){
		warn "Path $check_path not accessable: $!\n";
		next;
	}
	$killable = undef;
	
	opendir( DIR, $check_path ) or die "could not open path $check_path\n$!\n";
	$check_path .= "/" unless ( $check_path =~ m!/$! );
	foreach ( grep(!/^\./, readdir(DIR)) ){
		if ( -d "$check_path$_" ) {
			$killable->{"$check_path$_"} = 1;
		}
	}
	close(DIR);

	$master_level = scalar( split("/", $check_path)) +1;

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

	foreach ( keys %$killable ) {
		print "rm -Rf $_\n" if ( $killable->{$_} );
		system ( "rm -Rf $_" ) if ( $killable->{$_} );
	}
	
}

close ( PATHS  );

