#! /usr/bin/perl -w

#  Copyright (C) 2015-05-07 Stefan Lang

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

=head1 minimize_css.pl

run once to create/regenerate the css information

To get further help use 'minimize_css.pl -help' at the comman line.

=cut

use Getopt::Long;
use strict;
use warnings;

use stefans_libs::root;

use FindBin;
my $plugin_path = "$FindBin::Bin";

my $VERSION = 'v1.0';

my ( $help, $debug, $database, $source_file, $force,$target_file );

Getopt::Long::GetOptions(
	"-source_file=s" => \$source_file,
	"-target_file=s" => \$target_file,
	"-force"   => \$force,

	"-help"  => \$help,
	"-debug" => \$debug
);

my $warn  = '';
my $error = '';

unless ( defined $source_file ) {
	$source_file = "$plugin_path/../root/src/ttsite.css";
	$warn .= "the cmd line switch -source_file set to '$source_file'!\n";
}
unless ( defined $target_file ) {
	$target_file = "$plugin_path/../root/css/site.css";
	$warn .= "the cmd line switch -target_file set to '$target_file'!\n";
	$error .= "The target file exists - use -force to overwrite it" if ( -f $target_file && ! $force );
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
 command line switches for minimize_css.pl

   -source_file       :the old css file
   -target_file       :the new css file
   -force             :delete the target file if necessary
   -help           :print this help
   -debug          :verbose output
   

";
}

my ($task_description);

$task_description .=
  'perl ' . root->perl_include() . ' ' . $plugin_path . '/minimize_css.pl';
$task_description .= " -source_file $source_file" if ( defined $source_file );
$task_description .= " -target_file $target_file" if ( defined $target_file );

sub match_2_var {
	my ( $cols, $value ) = @_;
	my @tmp = split( /\./, $value );
	return $cols->{ join( ".", @tmp[ 0 .. ( @tmp - 2 ) ] ) }
	  ->{ $tmp[ @tmp - 1 ] };
}

unless ( -f "$plugin_path/../root/lib/config/col" ) {
	die
"Sorry I can not access the important file $plugin_path/../root/lib/config/col\n";
}
open( IN, "<$plugin_path/../root/lib/config/col" ) or die $!;
my ( $cols, $act );

while (<IN>) {
	if ( $_ =~ m/([\w\.]+)\s+=\s+{/ ) {
		$act = $1;
		next;
	}
	if ( $_ =~ m/([\w\.]+)\s+=\s+'([#\w\d\.]+)'/ ) {
		$cols->{"$act.$1"} = $2;

		#print  "\$cols->{ '$act.$1' } = $2;\n";
	}
	elsif ( $_ =~ m/([\w\.]+)\s+=\s+([\w\d\.]+)/ ) {
		$cols->{"$act.$1"} = $cols->{$2};

		#print  "\$cols->{ '$act.$1' } = $2;\n";
	}
}
close(IN);

#print "\$cols = ".root->print_perl_var_def( $cols ).";\n";
open( IN, "<$source_file" ) or die "could not open file '$source_file'\n" . $!;
my ( $css, $inv, $line, $tmp, $slots, $reparse, @order );
$reparse = 0;
while (<IN>) {
	next if ( $_ =~ m!^\s*/\*! );
	next if ( $_ =~ m!^\s*\<\!--! );
	next if $_ =~ m/^\s*}?\s*$/;
	if ( $_ =~ m/([#\w\d\.,\*\: ]*)\s*{/ ) {
		$act = $1;
		$act =~ s/\s+$//;
		$act =~ s/^\s+//;
		push ( @order, $act);
	}
	elsif ( $_ =~ m/^\s*#/ ) {
		next;
	}
	elsif ( $_ =~ m/\s*([\w\-]+)\s*([:=])(.+);?\s*$/ ) {
		my ( $A, $B, $C ) = ( $1, $3, $2 );
	#	print $_;
		foreach ( $A, $B ) {
			$_ =~ s/^\s+//;
			$_ =~ s/\s+$//;
			$_ =~ s/;//;
		}
		$line = "$A$C$B";
		if ( $_ =~ m/\[\s*%\s*(.+)\s*%\s*\]/ ) {
			$tmp = $1;
			$tmp =~ s/\s+$//;
			Carp::confess(
"I can not replace the variable '$tmp' as I do not know this variable! $_"
				  . "\$cols = "
				  . root->print_perl_var_def($cols)
				  . ";\n" )
			  unless ( defined $cols->{$tmp} );
			$line =~ s/\[\s*%\s*$tmp\s*%\s*\]/$cols->{$tmp}/;
		}

		$inv->{$line} ||= [];
		push( @{ $inv->{$line} }, $act);
		$css->{$act} ||= [];
		if ( defined $slots->{$act}->{$A} ) {
			@{ $css->{$act} }[ $slots->{$act}->{$A} ] = $line;
			$reparse = 1;
		}
		else {
			$slots->{$act}->{$A} = scalar( @{ $css->{$act} } );
				push( @{ $css->{$act} }, $line );
		}
		
	}
	else {
		die "Not processed line $_\n";
	}
}

close(IN);

if ( $reparse ){
	my $str = '';
	foreach my $key ( @order ) {
		$str .= "$key {\n".join(";\n",sort @{$css->{$key}}).";\n}\n";
	}
	open (TMP, ">tmp.css" ) or die "could not open the tmp.css!\n$!\n";
	print TMP $str;
	close ( TMP );
	die "Please re-run with  -source_file tmp.css\n";
}

#print "\$exp = ".root->print_perl_var_def( {'css' => $css, 'inv' => $inv } ).";\n";

## rebuilt the css
my $str = '';
my $ref_inv;
my $final;
foreach my $value ( keys %$inv ) {
	Carp::confess("$value in $inv is not an array!\n")
	  unless ( ref( $inv->{$value} ) eq "ARRAY" );
	if ( scalar( @{ $inv->{$value} } ) > 1 ) {
		$final->{ join( " ", @{ $inv->{$value} } ) } ||= [];
		push( @{ $final->{ join( " ", @{ $inv->{$value} } ) } }, $value );

		#	$str .= join(" ", @{$inv->{$value}} ). "{$value}\n";
	}
	else {
		$ref_inv->{ @{ $inv->{$value} }[0] } ||= [];
		push( @{ $ref_inv->{ @{ $inv->{$value} }[0] } }, $value );
	}
}
foreach my $key ( sort keys %$ref_inv ) {
	$str .= $key . "{" . join( ";", @{ $ref_inv->{$key} } ) . "}";
}
foreach my $key ( sort keys %$final ) {
	$str .= $key . "{" . join( ";", @{ $final->{$key} } ) . "}";
}
open( OUT, ">$target_file" )
  or die "I could not create the target file $target_file\n$!\n";
print OUT $str;
close(OUT);

print "File $target_file written!\n";
