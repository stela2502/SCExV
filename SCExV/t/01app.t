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

## check whether the data is OK
if ( $check->{'normalization'} ) {
	#############################
	$type = 'normalization none';
	#############################
	&test_analysis( $type, "/PCR_Array3.csv", "/preprocess/Ebf1.png" );

## check the other normalization method
	$mech->form_number(1);
	$mech->field( 'normalize2', 'quantil' );
	$mech->click_button( value => 'Apply' );
	ok(
		-f $path . "/" . "/preprocess/Ebf1.png",
		"Quantil Normalization did produce files"
	) or $drop_path = 0;
	## the normalization did not break the analysis

	$mech->form_number(1);
	$mech->field( 'normalize2', 'max expression' );
	$mech->click_button( value => 'Apply' );
	ok(
		-f $path . "/" . "/preprocess/Ebf1.png",
		"max expression Normalization did produce files"
	) or $drop_path = 0;
	## the normalization did not break the analysis

	$mech->form_number(1);
	$mech->field( 'normalize2', 'mean control genes' );
	$mech->field( 'controlG1',  'Actb' );
	$mech->field( 'controlG2',  'Gapdh' );
	$mech->click_button( value => 'Apply' );
	ok( -f $path . "/" . "/preprocess/Ebf1.png",
		"mean control genes Normalization did produce files" )
	  or $drop_path = 0;
	## the normalization did not break the analysis

	$mech->form_number(1);
	$mech->field( 'normalize2', 'median expression' );
	$mech->field( 'controlG1',  '' );
	$mech->field( 'controlG2',  '' );
	$mech->click_button( value => 'Apply' );
	ok( -f $path . "/" . "/preprocess/Ebf1.png",
		"median expression Normalization did produce files" )
	  or $drop_path = 0;
	## the normalization did not break the analysis

	## back to normal to not break the other tests
	$mech->form_number(1);
	$mech->field( 'normalize2', 'none' );
	$mech->click_button( value => 'Apply' );
	ok(
		-f $path . "/" . "/preprocess/Ebf1.png",
		"no Normalization - back to 0"
	) or $drop_path = 0;

}

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

########################
$type = 'first run scrapbook';
########################
$mech->get_ok(
"http://localhost/scrapbook/imageadd/http://localhostfiles/index$path/preprocess/Ebf1.png"
);
$mech->form_number(1);
$mech->field( 'Caption',
	"Test of a picture drawn to the scrapbook button. Javascript not checked!"
);
$mech->click_button( value => 'Submit' );
$mech->content_contains('<h3>File Upload</h3>')
  or $failed->{ $type . ' <h3>File Upload</h3>' } = 1;
$mech->content_contains('<h3>Analysis RUN</h3>')
  or $failed->{ $type . ' <h3>Analysis RUN</h3>' } = 1;
$mech->content_contains(
	'Test of a picture drawn to the scrapbook button. Javascript not checked!')
  or $failed->{ $type . ' ScrapBook text added' } = 1;
$mech->content_contains('Ebf1.png')
  or $failed->{ $type . ' ScrapBook picture file added' } = 1;

if ( $check->{'analysis'} ) {    ## in depth check of the analysis functions
	#############################
	$type = 'cluster_on Data values MDS 2 groups';
	#############################
	$mech->get_ok("http://localhost/analyse/index/");

	#&print_last_page("This might be a problem here:");
	$mech->form_number(1);
	$mech->field( 'cluster_on',     'Data values' );
	$mech->field( 'cluster_amount', 2 );
	$mech->click_button( value => 'Run Analysis' );
	&test_analysis($type);

	#############################
	$type = 'cluster_on FACS 2 groups';
	#############################
	$mech->form_number(1);
	$mech->field( 'cluster_by',     'FACS' );
	$mech->field( 'cluster_amount', 2 );
	$mech->click_button( value => 'Run Analysis' );
	&test_analysis($type);

	#############################
	$type = 'cluster_on Expression 2 groups kmeans';
	#############################
	$mech->field( 'cluster_type', 'kmeans' );
	$mech->field( 'cluster_by',   'Expression' );
	$mech->click_button( value => 'Run Analysis' );
	&test_analysis($type);

	#############################
	$type = 'default values';
	#############################
	$mech->field( 'cluster_type',   'hierarchical clust' );
	$mech->field( 'cluster_by',     'Expression' );
	$mech->field( 'cluster_on',     'MDS' );
	$mech->field( 'cluster_amount', 3 );
	$mech->click_button( value => 'Run Analysis' );
	&test_analysis($type);

	##todo I need to test the 2D sample removal tool!
	warn "I need to test the actually broken 2D sample removal tool!\n";
}

if ( $check->{'exclude cells'} ) {
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
	&test_analysis( $type, undef, '/merged_data_Table.xls',
		'/merged_FACS_Table.xls' );
}

if ( $check->{'exclude genes'} ) {
	#############################
	$type = 'After drop genes';
	#############################
	$mech->get_ok("http://localhost/dropgenes/index");
	## now I will drop all samples that do not have a FACS dataset.
	$mech->form_number(1);
	$mech->field( 'Genes', [ 'Gapdh', 'FSC.A', 'FSC.H', 'FSC.W' ] );
	$mech->click_button( value => 'Submit' );
	&test_analysis($type);
	foreach ( 'Gapdh', 'FSC.A', 'FSC.H', 'FSC.W' ) {
		ok( !-f $path . $_ . ".png",
			"file ' $path$_.png' does not exist any longer!" )
		  or $drop_path = 0;
	}
	&print_last_page("some genes were not removed from the analysis!")
	  unless ($drop_path);
}

warn
"I can not check the java functionallity of the page - check that manualy - please\n";

###########################
$type = 'regroup/reorder';
###########################
$mech->get_ok("http://localhost/regroup/reorder/");
my $old_grouping =
  data_table->new( { 'filename' => $path . "/Sample_Colors.xls" } );
$old_grouping = $old_grouping->GetAsHash( 'Samples', 'Cluster' );
$mech->form_number(1);
$mech->field( 'g1', "Group1 Group2" );
$mech->field( 'g2', "Group3" );
$mech->click_button( value => 'Submit' );

foreach ('/Grouping_GroupMerge') {
	ok( -f $path . $_, "file ' $path$_' exists" )
	  or $drop_path = 0;
}

my $new_grouping =
  data_table->new( { 'filename' => $path . "/Sample_Colors.xls" } );
$new_grouping = $new_grouping->GetAsHash( 'Samples', 'Cluster' );
foreach my $key ( keys %$old_grouping ) {
	if ( $old_grouping->{$key} == 3 ) {
		$old_grouping->{$key} = 2;
	}
	else {
		$old_grouping->{$key} = 1;
	}
}
is_deeply( $new_grouping, $old_grouping,
	'grouping information updated as expected' );
&test_analysis($type);

###########################
$type = 'gene_group';
###########################
$mech->get_ok("http://localhost/gene_group");
open( IN, $plugin_path . "/data/file_list_3.txt" );
foreach (<IN>) {
	chomp();
	ok( -f $path . $_, "file ' $path$_' exists" ) or $drop_path = 0;
}
close(IN);
test_analysis( $type, '/GG_prep/Actb.png' );
$mech->form_number(1);
$mech->field( 'GOI',    "Actb" );
$mech->field( 'cutoff', "26\t28 29,4  30 30.5" );
$mech->click_button( value => 'Update' );
$type = 'gene_group updated';
test_analysis( $type, '/GG_prep/Actb.png' );    ## should now contain lines!
$mech->click_button( value => 'Analyse using this grouping' );
$type = 'gene_group updated reanalysis';
ok(
	$mech->content() =~
m!<option selected="selected" value="Grouping.Actb">Grouping.Actb</option>!,
	'The analysis used the new group'
);
test_analysis($type);

##########################
$type = 'pvalues';
##########################
$mech->get_ok("http://localhost/pvalues/index/");
$mech->form_number(1);
$mech->click_button( value => 'Submit' );
test_analysis( $type, '/Significant_genes.csv', '/lin_lang_stats.xls',
	'/Summary_Stat_Outfile.xls' );

##########################
$type = 'Scrapbook_text';
##########################

$mech->get_ok("http://localhost/scrapbook/textadd/");
$mech->content_contains('<form action="/scrapbook/textadd/"');
$mech->form_number(1);
$mech->field( 'Text', "Here I add some useless text" );
$mech->click_button( value => 'Submit' );
foreach (
	'<h3>File Upload</h3>',
	'<h3>Analysis RUN</h3>',
	'<h3>Drop Samples (Cells)</h3>',
	'p><h3>Drop Genes</h3>',
	'<h3>Re-group your groups</h3>',
	'<h3>Create Grouing based on one gene</h3>',
	'<p>Here I add some useless text</p>'
  )
{
	$mech->content_contains($_) or $failed->{ $type . " $_" } = 1;
}

warn
"I can not check the Scapbook add 3D function automaticly, as that is mainly javascript and ajax based.\nPerform a manual test if this function might be broken.\n";

if ($drop_path) {
	system( 'rm -Rf ' . $path );
}
else {
	print "The problematic result files are in path '$path'\n";
	print "These are the failed tests:\n" . join( "\n", keys %$failed ) . "\n";
}

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
