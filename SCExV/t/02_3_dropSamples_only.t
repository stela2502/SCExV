#!/usr/bin/env perl
use strict;
use warnings;
use Test::More 'no_plan';
use Digest::MD5;

use Test::WWW::Mechanize::Catalyst "HTpcrA";
use stefans_libs::flexible_data_structures::data_table;

###### die on errors to recover the error state? ########

my $die_on_errors = 0;    ## set to 1 to shorten the execution time on errors

my $check = {
	'normalization' => 0,
	'analysis'      => 1,
	'exclude cells' => 1,    ## needs to run
	'exclude genes' => 1,    ## needs to run
};

#########################################################

use FindBin;
my $tmp_fail          = 0;
my $plugin_path       = "$FindBin::Bin";
my $failed            = {};
my $mech              = Test::WWW::Mechanize::Catalyst->new;
my $updates_Check_MD5 = {};
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

$mech->get_ok("http://localhost/files/use_example_data/");
$mech->content() =~
  m!http://localhost/files/index([/\w\-\.\d]+)/preprocess/Cdkn1a.png!;
my $path = $1;
ok( -d $path, "the data path has been created" );

my $drop_path = 1;
my ( $md5, $type );
#############################
$type = 'initial upload';
#############################
open( IN, $plugin_path . "/data/file_list_1.txt" );
foreach (<IN>) {
	chomp();
	unless (ok( -f $path . $_, "file ' $path$_' exists" )){
		 $drop_path = 0;
		 $failed->{ $type . "file ' $path$_' exists" } = 1;
	}
}
close(IN);
$mech->get_ok("http://localhost/files/upload/");

$mech->get_ok("http://localhost/analyse/run_first/");
########################
$type = 'first run';
########################
open( IN, $plugin_path . "/data/file_list_2.txt" );
foreach (<IN>) {
	chomp();
	unless (ok( -f $path . "/" . $_,"$type ' $path/$_' exists" ) ){
			$drop_path = 0;
			$failed->{ "$type ' $path/$_' exists" } = 1;
		}
}
close(IN);

$md5 = &file2md5str( $path . "/Ebf1.png" );
ok( $md5 eq 'o8SI0mmsUI8krKgyTApSJQ', 'first run Ebf1.png' )
  or &print_last_page("md5sum = '$md5'");
&test_analysis( $type,, "/Ebf1.png" );



#############################
$type = 'After drop samples';
#############################
$mech->get_ok("http://localhost/dropsamples/index");
## now I will drop all samples that do not have a FACS dataset.
$mech->form_number(1);
$mech->field( 'RegExp', 'NTC' );
$mech->click_button( value => 'Submit' );
&test_analysis($type);
#############################
$type = 'cluster_on FACS 3 groups';
#############################
$mech->form_number(1);
$mech->field( 'cluster_by',     'FACS' );
$mech->field( 'cluster_amount', 2 );
$mech->click_button( value => 'Run Analysis' );
&test_analysis( $type, undef, '/merged_data_Table.xls','/merged_FACS_Table.xls' );


		
####
## FUNCTIONS
####
sub test_analysis {
	my $str   = shift;
	my @files = @_;
	$files[0] ||= "/Sample_Colors.xls";
	$str ||= "analysis run failed";
	my $Sample_Colors = {
		'normalization none' =>
		  [ 'Gyxya47eoCxVXOov7tx0Yg', 'Knl9lKwdqht0ZrQlO0MHdQ' ],
		'first run'                           => ['o8SI0mmsUI8krKgyTApSJQ'],
		'After drop samples'                  => ['yEca7AHOZnyIRbL2nMG3Lw'],
		'After drop genes'                    => ['kU+JSZCyFtObwYgZdY8tEg'],
		'cluster_on Data values MDS 2 groups' => ['L6TMqw8hAp0dukreAU7z6g'],
		'cluster_on FACS 2 groups'            => 'no check'
		, ## FACS data in 6 samples is random and therefore a problem in reproducability!
		'cluster_on Expression 2 groups kmeans' =>
		  'no check',    ## kmeans is not 100% reproducable either!
		'default values'           => 'no check',
		'cluster_on FACS 3 groups' => [
			'kU+JSZCyFtObwYgZdY8tEg', '7zpNExkKG4viKAb2RpP5sQ',
			'CAFJ/8CFMc6Wz3VzD92TJw'
		],
		'regroup/reorder'               => ['kPBoIEPFyHctEEwLtU20DQ'],
		'gene_group'                    => ['D9UWmG5VJun/ORWuAVPU+Q'],
		'gene_group updated'            => ['SKgr9zfYwSLAhc1IgFKw1g'],
		'gene_group updated reanalysis' => ['CF/I0fSUkTyhqGvZrKO4/Q'],
		'pvalues'                       => 'no check',
	};
	unless ( $Sample_Colors->{$str} eq 'no check' ) {
		for ( my $i = 0 ; $i < @files ; $i++ ) {
			$md5 = &file2md5str( $path . $files[$i] );
			$updates_Check_MD5->{$str} = []
			  unless ( ref( $updates_Check_MD5->{$str} ) eq "ARRAY" );
			@{ $updates_Check_MD5->{$str} }[$i] = $md5;
			$tmp_fail = 1;
			ok( $md5 eq @{ $Sample_Colors->{$str} }[$i], "$str: $files[$i]" )
			  or &print_last_page("$str: $files[$i]; md5sum = '$md5'");
			$tmp_fail = 0;
		}
	}
	else {
		$updates_Check_MD5->{$str} = 'no check';
		for ( my $i = 0 ; $i < @files ; $i++ ) {
			$tmp_fail = 1;
			ok( -f $path . $files[$i], "$str: $files[$i] exists" )
			  or &print_last_page("$str: $files[$i] file does not exist");
			$tmp_fail = 0;
		}
	}
	unless ( $str =~ m/normalization/ ) {
		$tmp_fail = 0;
		foreach (
			"Lineage.PE.Cy5.A.png",          'Ebf1.png',
			"PCR_color_groups_Heatmap.png",  "PCR_Heatmap.png",
			"facs_color_groups_Heatmap.png", "facs_Heatmap.png"
		  )
		{
			unless ( ok( -f $path . "/" . $_, "$str: file ' $path/$_' exists" ) ){
				$failed->{ "$str: file ' $path/$_' exists"  } = 1;
			  	$tmp_fail = 1;
			}
		}
		&print_last_page( $str . " built in files" ) if ($tmp_fail);
		$tmp_fail = 0;
	}
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
	print
"The SampleColors hash in the test_analysis function might need an update:\n\$Sample_Colors = "
	  . root->print_perl_var_def($updates_Check_MD5) . ";\n";
	Carp::confess($str) if ($die_on_errors);
	Carp::cluck($str);
}

sub file2md5str {
	my ( $filename, $binmode ) = @_;
	$binmode ||= 1;
	my $md5_sum = 0;
	if ( -f $filename ) {
		open( FILE, "<$filename" );
		binmode FILE if ($binmode);
		my $ctx = Digest::MD5->new;
		$ctx->addfile(*FILE);
		$md5_sum = $ctx->b64digest;
		close(FILE);
	}
	return $md5_sum;
}
		