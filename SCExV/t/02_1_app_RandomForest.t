#!/usr/bin/env perl
use strict;
use warnings;
use Test::More 'no_plan';
use Digest::MD5;

use Test::WWW::Mechanize::Catalyst "HTpcrA";
use stefans_libs::flexible_data_structures::data_table;


BEGIN { use_ok 'HTpcrA::Model::RandomForest' }

my $obj = HTpcrA::Model::RandomForest->new();


###### die on errors to recover the error state? ########

my $die_on_errors = 0;    ## set to 1 to shorten the execution time on errors
my $run_on_server = 0;
my $check = {
	'normalization' => 0,
	'analysis'      => 1,
	'exclude cells' => 1,    ## needs to run
	'exclude genes' => 1,    ## needs to run
};

#########################################################

use FindBin;
my $tmp_fail    = 0;
my $plugin_path = "$FindBin::Bin";
my $outfile = $plugin_path."/data/Output/RandomForestAnalysis.zip";
# I will use the files
# $plugin_path/../root/example_data/PCR\ Array2.csv and
# $plugin_path/../root/example_data/Index\ sort\ Array2.csv
# for this test.

my @PCR_files  = ("$plugin_path/../root/example_data/PCR Array2.csv");
my @FACS_files = ("$plugin_path/../root/example_data/Index sort Array2.csv");
my ( $norm_method, $groups, $group_on_datatype, $group_on_analysis,
	$randomForest, $MDS_type, $cluster_function );
$norm_method       = 'median expression';
$group_on_datatype = 'Expression';
$group_on_analysis = 'MDS';
$MDS_type          = 'PCA';
$cluster_function  = 'hierarchical clust';
my $drop_path = 0;
my $failed    = {};
my $mech      = Test::WWW::Mechanize::Catalyst->new;
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
$mech->field( 'normalize2', 'none' );
for ( my $i = 0 ; $i < @PCR_files ; $i++ ) {
	$mech->form_number(1) if ( $i > 0 );
	$mech->field( 'PCRTable', $PCR_files[$i] );
	if ( -f $FACS_files[$i] ) {
		$mech->field( 'facsTable', $FACS_files[$i] );
	}
	$mech->click_button( value => 'Apply' );
}

$mech->content() =~ m!http://localhost/files/index([/\w\-\.\d]+)/preprocess/!;
my $path = $1;
ok( -d $path, 'Path exists' )
  or die
"Some internal problems with the server - I was unable to identify the server data path!";
ok(
	-f $path . "/" . "/norm_data.RData",
	"Quantil Normalization did produce files"
  )
  or
  &finalize("error on file upload - norm_data.RData has not been created!\n");

$mech->get_ok("http://localhost/analyse/index");
my ( $md5, $type );

$type = "Analysis";

$mech->form_number(1);
#$mech->field( 'cluster_by',     $group_on_datatype );
#$mech->field( 'cluster_on',     $group_on_analysis );
#$mech->field( 'cluster_amount', $groups );
#$mech->field( 'mds_alg',        $MDS_type );
#$mech->field( 'cluster_type',   $cluster_function );
$mech->click_button( value => 'Run Analysis' );
&test_analysis($type);

## add the randomForest test

$mech->get_ok("http://localhost/randomforest/recalculate");
$mech->form_number(1);
$mech->field( 'total_trees', 6e+5 );    ## one tenth of the normal - speed up!
if ( $run_on_server) {
	$mech->click_button( value => 'Submit' );
}
else {
	$mech->get_ok("http://localhost/analyse/index/");
	$obj->RandomForest( test::c->new($path), {'not_calculate' => 1, 'total_trees' =>  6e+5, 'cluster_on' =>  'Expression', 'gene_groups' => 10 },1  );
}
## now we get back to the analysis page...
## This analysis will not work as the external server can not contact the local test server!
## use the precompiled version of the file
## $plugin_path/data/RandomForest_transfereBack.tar.gz

$mech->content_contains('Group by plateID'); ## got back to the analysis page
$mech->get_ok("http://localhost/randomforest/index");
$mech->form_number(1);
my $session = $1 if ( $path=~ m!tmp/(.*)/! );
$mech->field( 'session', $session );
$mech->field( 'fn', "$plugin_path/data/RandomForest_transfereBack.tar.gz" );
$mech->field( 'md5', 'zSk7D8Q0L//9ZY7G/x71LA' );
$mech->click_button( value => 'Submit' );
$mech->content_contains('Done') or Carp::confess( $mech->content());

ok( -f $path."RandomForest_transfereBack.tar.gz", 'random forest file 1');
ok( -f $path."RandomForestdistRFobject_genes.RData", 'random forest file 2');
ok( -f $path."RandomForestdistRFobject.RData", 'random forest file 3');

$mech->get_ok("http://localhost/analyse/index");
$mech->field( 'UG' , 'Grouping.randomForest.n10.txt' );
$mech->click_button( value => 'Run Analysis' );
&test_analysis($type);

## re-normalize and redo random forest...
$mech->get_ok("http://localhost/files/upload/");
$mech->field( 'normalize2', 'median expression' );
$mech->click_button( value => 'Apply' );
$mech->get_ok("http://localhost/analyse/index/");
$mech->click_button( value => 'Run Analysis' );

system ( "find $path > $path/find_before_upload.txt" );
$mech->get_ok("http://localhost/randomforest/index");
$mech->form_number(1);
$mech->field( 'session', $session );
$mech->field( 'fn', "$plugin_path/data/RandomForest_transfereBack_new.tar.gz" );
$mech->field( 'md5', 'up/jxKhm+OnPF2rgpO5VuA' );
$mech->click_button( value => 'Submit' );
$mech->content_contains('Done') or Carp::confess ( $mech->content());
&finalize("The process finished without errors.\n");


$mech->get_ok("http://localhost/analyse/index");
$mech->field( 'UG' , 'Grouping.randomForest.n10.txt' );
$mech->click_button( value => 'Run Analysis' );
&test_analysis($type);


&finalize("The process finished without errors.\n");

sub finalize {
	my $str = shift;
	$mech->get_ok("http://localhost/files/as_zip_file/");
	$mech->click_button( value => 'Submit' );
	system("cp $path*.zip $outfile");
}

sub test_analysis {
	my $str   = shift;
	my @files = @_;
	$files[0] ||= "/Sample_Colors.xls";
	$str ||= "analysis run failed";
	$tmp_fail = 0;
	foreach ( "PCR_color_groups_Heatmap.svg", "PCR_Heatmap.svg" ) {
		unless ( ok( -f $path . "/" . $_, "$str: file ' $path/$_' exists" ) ) {
			$failed->{"$str: file ' $path/$_' exists"} = 1;
			$tmp_fail = 1;
		}
	}
	if ( -f $FACS_files[0] ) {
		foreach ( "facs_color_groups_Heatmap.svg", "facs_Heatmap.svg" ) {
			unless (
				ok( -f $path . "/" . $_, "$str: file ' $path/$_' exists" ) )
			{
				$failed->{"$str: file ' $path/$_' exists"} = 1;
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
	&finalize($str);
}





package test::c;
use strict;
use warnings;

use FindBin;
my $plugin_path = "$FindBin::Bin";

sub new {
	my ( $class, $session_path ) = @_;
	my $self = {
		'session_path' => $session_path,
		'config' => {
			'ncore'      => 4,
			'calcserver' => {
				'ncore'   => 32,
				'ip'      => '127.0.0.1',
				'subpage' => "/weblog/fluidigm/"
			}
		  }

	};
	bless $self, shift;
	return $self;
}

sub session_path {
	my ( $self ) = @_;
	return $self->{'session_path'} if ( -d $self->{'session_path'} );
	my $p = "$FindBin::Bin" . "/data/Output/randomForestTest/";
	unless ( -d $p ) {
		mkdir($p);
		mkdir( $p . 'libs' );
	}
	system( "touch $p" . 'libs/Tool_RandomForest.R' );
	system( "touch $p" . 'libs/Tool_grouping.R' );
	system( "touch $p" . "norm_data.RData" );

	return $p;
}

sub config {    ## Catalyst function
	return shift->{'config'};
}

sub model {     ## Catalyst function
	my ( $self, $name ) = @_;
	return sender->new();

}
sub uri_for {
	my $str = shift;
	return "http://localhost/$str";
}
sub get_session_id {    ## Catalyst function
	return 1234556778;
}

package sender;
use strict;
use warnings;

sub new {
	my $self = {};
	bless $self, shift;
	return $self;
}

sub post_randomForest {
	my ( $self, $to, $what ) = @_;
	root::print_hashEntries( { 'to' => $to, 'what' => $what },
		4, "the call to mechanize->post:" );
}

