#! /usr/bin/perl -d:NYTProf
use strict;
use warnings;
use Test::More tests => 11;


use FindBin;
my $plugin_path = "$FindBin::Bin";
my $path = $plugin_path."/data/Output/R_run/";
my $Rlib_path = $plugin_path."/../root/R_lib/";

mkdir ( "/data/Output/") unless ( -d "/data/Output/" );
mkdir ($path) unless (-d $path);
my $use_Fail_Pass = 1;

sub run_R {
	my $dataset = shift;

	my $script = "source('$Rlib_path"."Tool_Pipe.R')\n"."source('$Rlib_path"."Tool_Plot.R')\n"
	. "negContrGenes <- NULL\n";
   $script .= 
	   "negContrGenes <- c ( '".join("', '",@{$dataset->{'negControllGenes'}}). "')\n" if (defined @{$dataset->{'negControllGenes'}}[0]  );
	$script .=    
	  "data.filtered <- createDataObj ( PCR= c( '"
	  . join( "', '", @{ $dataset->{'PCRTable'} } )
	  . "' ), "
	  . "FACS= c( '"
	  . join( "','", @{ $dataset->{'facsTable'} } )
	  . "' ), "
	  . "ref.genes= c( '"
	  . join( "', '", @{ $dataset->{'controlM'} } ) . "' ),"
	  . "max.value=40, max.ct= $dataset->{'maxCT'} , max.control=$dataset->{'maxGenes'}, "
	  . " use_pass_fail = '$dataset->{'use_pass_fail'}', "
	  ."  norm.function='$dataset->{'normalize2'}', negContrGenes=negContrGenes )\n"
	  ."save( data.filtered, file='../norm_data.RData' )\n";
	$script =~ s/c\( '.?.?\/?' \)/NULL/g;
	
	open( RSCRIPT, ">$path/Preprocess.R" )
	  or Carp::confess(
		"I could not create the R script '$path/Preprocess.R'\n$!\n");
	print RSCRIPT $script;
	chdir($path);
	system(
'/bin/bash -c "DISPLAY=:7 R CMD BATCH --no-readline -- Preprocess.R > R.pre.run.log"'
	);
	
}

my $contr_hash = {
	'negControllGenes' => [],
	'PCRTable' => [],
	'facsTable' => [],
	'controlM' => [], ##control genes
	'maxCT' => 40,
	'maxGenes' => 0, ## how manny control genes may fail before the sample is excluded
	                 ## 'any', 'more than 1', 'more than 2', 'all 4' 
	'use_pass_fail' => 'T',
	'normalize2' => 'none', # one of 'max expression', 'mean control genes', 'quantile', 'none'
	'negControllGenes' => [], ## the negaive control genes - expression in the gene removes the sample
};

my @source_files = ( 'PCR_Heatmap.csv',  'Excel_Tab_separated.csv',  'PCR_Table.csv', 'PCR_Table_2.csv', '113129216_y112_P-F.csv');

system ("rm $path*" );

for ( my $i = 0; $i < @source_files; $i ++ ){
	unlink ( $path."/boxplot_filtered_samples.svg") if ( -f  $path."/boxplot_filtered_samples.svg" );
	eval{system ( "rm ".$path."/*.png")};
	$contr_hash->{'PCRTable'} = [ $plugin_path."/data/source_data/".$source_files[$i] ];
	&run_R($contr_hash);
	ok (-f  $path."boxplot_filtered_samples.svg",  "$source_files[$i] working" );
	unless (-f $path."boxplot_filtered_samples.svg" ) {
		system( "cp $path"."Preprocess.R '$path"."$source_files[$i]_failed_Preprocess.R'");
	}
	if ( $source_files[$i] eq "113129216_y112_P-F.csv"){ ## ERG expression artificially set to Fail in all samples
		ok ( ! -f $path."ERG.png", "Pass/Fail evaluation PCR heatmap" );
		$contr_hash -> {'use_pass_fail'} = 'F';
		&run_R($contr_hash);
		ok ( -f $path."ERG.png", "Pass/Fail evaluation PCR heatmap (OFF)" );
		$contr_hash -> {'use_pass_fail'} = 'T';
	}
	if ( $source_files[$i] eq "PCR_Table.csv"){ ## ERG expression artificially set to Fail in all samples
		ok ( ! -f $path."ERG.png", "Pass/Fail evaluation PCR table" );
		## g/ERG/s/Pass/Fail/g
		$contr_hash -> {'use_pass_fail'} = 'F';
		&run_R($contr_hash);
		ok ( -f $path."ERG.png", "Pass/Fail evaluation PCR table (OFF)" );
		$contr_hash -> {'use_pass_fail'} = 'T';
	}
}

unlink ( $path."/boxplot_filtered_samples.svg") if ( -f  $path."/boxplot_filtered_samples.svg" );
eval{system ( "rm ".$path."/*.png")};
$contr_hash->{'PCRTable'} = [ $plugin_path."/data/source_data/Unreadable_modified_Heatmap.csv" ];
&run_R($contr_hash);
ok (!( -f  $path."boxplot_filtered_samples.svg"),  "Unreadable file not readable!");
ok ( -f  $path."R_file_read_error.txt" ,"Unreadable file creates an error message" );



