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

$mech->get_ok("http://localhost/files/start_from_zip_file");
$mech->form_number(1);
$mech->field( 'zipfile', $plugin_path."/data/TestDatasetAnalyzed.zip" );
$mech->click_button( value => 'Submit' );


$mech->content() =~
  m!http://localhost/files/index([/\w\-\.\d]+)/PCR_Heatmap.png!;
my $path = $1;
ok( -d $path, "the data path has been created" ) or die $mech->content()."\nInitial file load error";

my @expected_files = ( map {"/$_" } (map {("Gene$_.png", "preprocess/Gene$_.png") } 'H','F', 'B', 'C1', 'C2', 'D'), 'PCR_color_groups_data4Genesis.xls', 
'PCR_color_groups_Heatmap.png', 'norm_data.RData', 'densityWebGL/index.html' , 'libs/Tool_Plot.R' , 'webGL/index.html', 'webGL/MDS_2D.png' );

my $drop_path = 1;
my ( $md5, $type );
#############################
$type = 'initial upload';
#############################
foreach (@expected_files) {
	chomp();
	unless (ok( -f $path . $_, "file ' $path$_' exists" )){
		 $drop_path = 0;
		 $failed->{ $type . "file ' $path$_' exists" } = 1;
	}
}

&test_analysis( $type );

#############################
$type = 're_analyse';
#############################

eval {$mech->get_ok("http://localhost/analyse/re_run")};
foreach (@expected_files) {
	chomp();
	unless (ok( -f $path . $_, "file ' $path$_' exists" )){
		 $drop_path = 0;
		 $failed->{ $type . "file ' $path$_' exists" } = 1;
	}
}
&test_analysis($type, );

#############################
#$type = 'cluster_on FACS 3 groups';
#############################
#$mech->form_number(1);
#$mech->field( 'cluster_by',     'FACS' );
#$mech->field( 'cluster_amount', 2 );
#$mech->click_button( value => 'Run Analysis' );
#&test_analysis( $type, undef, '/merged_data_Table.xls','/merged_FACS_Table.xls' );


		
####
## FUNCTIONS
####
sub test_analysis {
	my $str   = shift;
	my @files = @_;
	$files[0] ||= "/Sample_Colors.xls";
	$str ||= "analysis run failed";
	my $Sample_Colors = {
		'initial upload' => [ 'ZNdnF8lAXjWY5hjIfP6MGw' ],
		 're_analyse' => [ 'N37/qboLstZLlCF5YY6+Ew' ],
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
			"PCR_color_groups_Heatmap.png",  "PCR_Heatmap.png",
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
		