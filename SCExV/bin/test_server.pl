#! /usr/bin/perl -w

#  Copyright (C) 2015-04-13 Stefan Lang

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

=head1 test_server.pl

This script starts the test server and checks some standard functionallity.

To get further help use 'test_server.pl -help' at the comman line.

=cut

use Getopt::Long;
use strict;
use warnings;

use Test::WWW::Mechanize::Catalyst "HTpcrA";
use stefans_libs::flexible_data_structures::data_table;

use FindBin;
my $plugin_path = "$FindBin::Bin";

my $VERSION = 'v1.0';




use Test::More 'no_plan';
use Digest::MD5;

my ( $help, $debug, $database, @PCR_files, @FACS_files, $norm_method, $groups, $group_on_datatype, $group_on_analysis, $randomForest, $MDS_type, $cluster_function, $outfile);

Getopt::Long::GetOptions(
         "-PCR_files=s{,}"    => \@PCR_files,
         "-FACS_files=s{,}"    => \@FACS_files,
         "-norm_method=s"    => \$norm_method,
         "-groups=s"    => \$groups,
         "-group_on_datatype=s"    => \$group_on_datatype,
         "-group_on_analysis=s"    => \$group_on_analysis,
         "-randomForest"    => \$randomForest,
         "-MDS_type=s"    => \$MDS_type,
         "-cluster_function=s"    => \$cluster_function,
		 "-outfile=s"    => \$outfile,
         "-help"             => \$help,
         "-debug"            => \$debug
);


my $warn = '';
my $error = '';

unless ( defined $PCR_files[0]) {
        $error .= "the cmd line switch -PCR_files is undefined!\n";
}
unless ( defined $FACS_files[0]) {
        $warn .= "the cmd line switch -FACS_files is undefined!\n";
}
unless ( defined $norm_method) {
        $warn .= "the cmd line switch -norm_method is undefined!\n";
        $norm_method = 'median expression'
}
unless ( defined $groups) {
        $error .= "the cmd line switch -groups is undefined!\n";
}
unless ( defined $group_on_datatype) {
        $warn .= "the cmd line switch -group_on_datatype is undefined!\n";
        $group_on_datatype = 'Expression';
}
unless ( defined $group_on_analysis) {
        $warn .= "the cmd line switch -group_on_analysis is undefined!\n";
        $group_on_analysis = 'MDS'
}
unless ( defined $MDS_type) {
        $warn .= "the cmd line switch -MDS_type is undefined!\n";
        $MDS_type = 'PCA';
}
unless ( defined $cluster_function) {
        $warn .= "the cmd line switch -cluster_function is undefined!\n";
        $cluster_function = 'hierarchical clust';
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
 command line switches for test_server.pl

   -PCR_files          :a list of PCR datasets to analyze
   -FACS_files         :a list of FACS datasets to analyze
   -norm_method        :one out of (default) 'median expression', 'none' and 'max expression'
   -groups             :a number higher than 2
   -group_on_datatype  :group on 'Expression' (PCR) or 'FACS' data
   -group_on_analysis  :group on analysis 'MDS' or 'Data values' (no re-formating)
   -randomForest       :use or not use randomForest analysis (slow)
   -MDS_type           :'PCA', 'LLE' or'ISOMAP'
   -cluster_function   :'hirarchical clust' or 'kmeans'
   -outfile            :the zip outfile - you can not upload that to any server!
   
   -help           :print this help
   -debug          :verbose output
   

";
}

my ( $task_description);

$task_description .= 'perl '.root->perl_include().' '.$plugin_path .'/test_server.pl';
$task_description .= ' -PCR_files '.join( ' ', \@PCR_files ) if ( defined $PCR_files[0]);
$task_description .= ' -FACS_files '.join( ' ', \@FACS_files ) if ( defined $FACS_files[0]);
$task_description .= " -norm_method $norm_method" if (defined $norm_method);
$task_description .= " -groups $groups" if (defined $groups);
$task_description .= " -group_on_datatype $group_on_datatype" if (defined $group_on_datatype);
$task_description .= " -group_on_analysis $group_on_analysis" if (defined $group_on_analysis);
$task_description .= " -randomForest $randomForest" if (defined $randomForest);
$task_description .= " -MDS_type $MDS_type" if (defined $MDS_type);
$task_description .= " -cluster_function $cluster_function" if (defined $cluster_function);
$task_description .= " -outfile $outfile" if (defined $outfile);


my $die_on_errors = 1;
my $tmp_fail          = 1;
my $drop_path = 0;
my $failed            = {};
my $mech              = Test::WWW::Mechanize::Catalyst->new;
$mech->get_ok("http://localhost/");
$mech->content_contains( 'http://localhost/files/upload/',
	'Link to file upload' );
$mech->content_contains( 'http://localhost/files/use_example_data/',
	'Link to file built in dataset' );
$mech->content_contains(
'This page uses cookies that contain a unique identifier for one session. Without cookies you will not be able to use this page. No tracking!',
	'Cookie warning'
);

$mech->get_ok("http://localhost/");
$mech->content_lacks(
'This page uses cookies that contain a unique identifier for one session. Without cookies you will not be able to use this page. No tracking!',
	'Cookie warning is gone'
);
$mech->get_ok("http://localhost/files/upload/");
$mech->form_number(1);
$mech->field( 'normalize2' , $norm_method );
for ( my $i = 0; $i < @PCR_files; $i ++ ){
	$mech->form_number(1) if ( $i > 0 );
	$mech->field( 'PCRTable' ,  $PCR_files[$i] );
	if ( -f $FACS_files[$i] ){
		$mech->field( 'facsTable',  $FACS_files[$i] );
	}
	$mech->click_button( value => 'Apply' );
}

$mech->content() =~
  m!http://localhost/files/index([/\w\-\.\d]+)/preprocess/!;
my $path = $1;
ok( -d $path ) or die "Some internal problems with the server - I was unable to identify the server data path!";
ok(
	-f $path . "/" . "/norm_data.RData",
	"Quantil Normalization did produce files"
) or &finalize( "error on file upload - norm_data.RData has not been created!\n" );

$mech->get_ok("http://localhost/analyse/index" );
my ( $md5, $type );

$type = "Analysis";

$mech->form_number(1);
$mech->field( 'cluster_by',  $group_on_datatype);
$mech->field( 'cluster_on',  $group_on_analysis );
$mech->field( 'cluster_amount', $groups );
$mech->field( 'mds_alg', $MDS_type);
$mech->field( 'cluster_type', $cluster_function);
$mech->click_button( value => 'Run Analysis' );
&test_analysis($type);
if ( scalar(keys %$failed) > 0 ){
	&finalize( join("\n", keys %$failed )."\n" );
} 

&finalize( "The process finished without errors.\n" );


sub finalize {
	my $str = shift;
	$mech->get_ok("http://localhost/files/as_zip_file/");
	$mech->click_button(value => 'Submit');
	system ( "cp $path*.zip $outfile" );
}

sub test_analysis {
	my $str   = shift;
	my @files = @_;
	$files[0] ||= "/Sample_Colors.xls";
	$str ||= "analysis run failed";
	$tmp_fail = 0;
	foreach ( "PCR_color_groups_Heatmap.svg",  "PCR_Heatmap.svg" ){
		unless ( ok( -f $path . "/" . $_, "$str: file ' $path/$_' exists" ) ){
			$failed->{ "$str: file ' $path/$_' exists"  } = 1;
		  	$tmp_fail = 1;
		}
	}
	if ( -f $FACS_files[0] ){
	foreach (  "facs_color_groups_Heatmap.svg", "facs_Heatmap.svg" ){
		unless ( ok( -f $path . "/" . $_, "$str: file ' $path/$_' exists" ) ){
				$failed->{ "$str: file ' $path/$_' exists"  } = 1;
			  	$tmp_fail = 1;
			}
	}
	}
	&print_last_page( $str . " built in files" ) if ($tmp_fail);
	$tmp_fail = 0;
}


sub print_last_page {
	my $str = shift;
	$str ||= 'no message';
	$failed->{$str} = 1 if ( $str =~ m/md5sum/ );
	$drop_path = 0;
	open( OUT, ">$path" . "/some_file.html" );
	my $out = $mech->content();
	$out =~ s!http://localhost/files/index$path/!./!g;
	print OUT $out;
	close(OUT);
	Carp::cluck($str);
}
