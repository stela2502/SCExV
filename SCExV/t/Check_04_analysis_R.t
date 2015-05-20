#! /usr/bin/perl -d:NYTProf
use strict;
use warnings;
use Test::More tests => 99;

use FindBin;
my $plugin_path = "$FindBin::Bin";
my $path        = $plugin_path . "/data/Output/R_run2/";
my $Rlib_path   = $plugin_path . "/../root/R_lib/";

my $preprocess_hash = {
	'negControllGenes' => [],
	'PCRTable' =>
	  [ $plugin_path . "/data/source_data/INDEX_PCR.csv" ],
	'facsTable' => [ $plugin_path . "/data/source_data/INDEX_Sorted.csv" ],
	'controlM' => [],    ##control genes
	'maxCT'    => 40,
	'maxGenes' =>
	  0,    ## how manny control genes may fail before the sample is excluded
	## 'any', 'more than 1', 'more than 2', 'all 4'
	'use_pass_fail' => 'T',
	'normalize2'    => 'none'
	,       # one of 'max expression', 'mean control genes', 'quantile', 'none'
	'negControllGenes' => []
	,   ## the negaive control genes - expression in the gene removes the sample
};

system("mkdir -p $path/preprocess/") unless ( -d "$path/preprocess/" );

unlink( $path . "/preprocess/boxplot_filtered_samples.svg" )
  if ( -f $path . "/preprocess/boxplot_filtered_samples.svg" );
eval { system( "rm " . $path . "/preprocess/*.png" ) };

&run_R_preprocess($preprocess_hash);
ok( -f $path . "/preprocess/boxplot_filtered_samples.svg",
	"preprocess PCR and FACS working" );

foreach (
	qw(actin.png Cd34.png Dicer1.png Dnmt3b.png Egr1.png Flt3.png Gata2.png Hoxa9.png Id1.png Il18.png Kit.png Meis1.png Myc.png Rag2.png Sox4.png vwf.png
	Bmi1.png Cd48.png Dnmt1.png Dntt.png Evi1a.png gapdh.png Gfi1b.png Hoxb5.png Id2.png Il7r.png Max.png Mpl.png Pax5.png Sfpi.png Tal1.png zfp521.png
	Cbx2.png Cebpa.png Dnmt3a.png Ebf1.png Ezh2.png Gata1.png Hlf.png hprt.png ikaros.png Jam2.png Mds1-Evi1_Cust.png Myb.png Rag1.png Slamf1.png Tcfe2a.png
	../norm_data.RData)
  )
{
	ok( -f $path . "/preprocess/$_", "preprocess outfile $_" );
}

my $analysis_hash = {
	'UG'             => 'select',      # 'Group by plateID'
	'cluster_amount' => 3,
	'cluster_by'     => 'PCR',    #'FACS', # 'PCR'
	'cluster_on'     => 'MDS',         # 'raw'
	'mds_alg'        => 'PCA',         # 'ISOMAP' 'LLE'
	'cluster_alg'    => 'ward.D',
	'K'              => 2,
};

my $id = 1;

#system ( "rm -R $path/)
&run_R_analysis($analysis_hash);
&check_outfiles_analysis('PCR 3 groups MDS PCA ward.D');

$analysis_hash ->{'mds_alg'} = 'ISOMAP';
&run_R_analysis($analysis_hash);
&check_outfiles_analysis('PCR 3 groups MDS ISOMAP ward.D');


$analysis_hash ->{'mds_alg'} = 'LLE';
&run_R_analysis($analysis_hash);
&check_outfiles_analysis('PCR 3 groups MDS LLE ward.D');

$analysis_hash ->{'mds_alg'} = 'ISOMAP';
$analysis_hash ->{'cluster_by'} = 'FACS';

&run_R_analysis($analysis_hash);
&check_outfiles_analysis('FACS 3 groups MDS ISOMAP ward.D');

$analysis_hash->{'cluster_on'} = 'raw';
&run_R_analysis($analysis_hash);
&check_outfiles_analysis();

## check outfiles add 10 tests per run

print "Done\n";

sub hash_to_str{
	my ($d) = @_;
	my $ret = '';
	foreach ( qw(cluster_by mds_alg cluster_on) ) {
		$ret .= $d->{$_}." ";
	}
	return $ret;
}
sub check_outfiles_analysis {
	my $check_type = &hash_to_str($analysis_hash);
	foreach (
		qw(facs_color_groups_Heatmap.svg  facs_Heatmap.svg  PCR_color_groups_Heatmap.svg  PCR_Heatmap.svg
		Dntt.png Id1.png Lineage.PE.Cy5.A.png merged_mdsCoord.xls webGL/index.html webGL/MDS_2D.png)
	  )
	{
		ok( -f $path . "$_", "Test: " . $check_type . " File: " . $_ );
	}
}


sub run_R_analysis {
	my ($dataset) = @_;
	system ( "rm -R $path/*.png $path/webGL $path/*.svg" );
	my $script =
	    "source('$Rlib_path"
	  . "Tool_Pipe.R')\n"
	  . "source('$Rlib_path"
	  . "Tool_Plot.R')\n"
	  . "load( 'norm_data.RData')\n";

	if ( $dataset->{'UG'} eq "Group by plateID" ) {
		$script .=
		    "userGroups <- list(groupID = data.filtered\$ArrayID ) \n "
		  . "groups.n <-length (levels(as.factor(userGroups\$groupID) ))\n ";
	}
	elsif ( -f $path . $dataset->{'UG'} ) {    ## an expression based grouping!
		$script .= "source ('$dataset->{'UG'}')\n"
		  . "groups.n <-length (levels(as.factor(userGroups\$groupID) ))\n ";
	}
	else {
		$script .= "groups.n <-$dataset->{'cluster_amount'}\n";
	}

	$script .=
"onwhat='$dataset->{'cluster_by'}'\ndata <- analyse.data ( data.filtered, groups.n=groups.n, 
onwhat='$dataset->{'cluster_by'}', clusterby='$dataset->{'cluster_on'}', mds.type='$dataset->{'mds_alg'}', cmethod='$dataset->{'cluster_alg'}', LLEK='$dataset->{'K'}' )"
	  . "\nsave( data, file='analysis.RData' )\n\n";

	## now lets identify the most interesting genes:
	$script .=
	    "GOI <- get.GOI( data\$z\$PCR, data\$clusters, exclude= -20 )\n"
	  . "if ( ! is.null(data\$PCR)) {\n"
	  . "    rbind( GOI, get.GOI( data\$z\$PCR, data\$clusters, exclude= -20 ) ) \n}\n"
	  . "write.table( GOI, file='GOI.xls' )\n\n";

	$script .=
"write.table( cbind( Samples = rownames(data\$PCR), data\$PCR ), file='merged_data_Table.xls' , row.names=F, sep='\t',quote=F )\n"
	  . "if ( ! is.null(data\$FACS)){\n"
	  . "write.table( cbind( Samples = rownames(data\$FACS), data\$FACS ), file='merged_FACS_Table.xls' , row.names=F, sep='\t',quote=F )\n"
	  . "}\n"
	  . "write.table( cbind( Samples = rownames(data\$mds.coord), data\$mds.coord ), file='merged_mdsCoord.xls' , row.names=F, sep='\t',quote=F )\n\n"
	  . "## the lists in one file\n\n"
	  . "write.table( cbind( Samples = rownames(data\$PCR), ArrayID = data\$ArrayID, Cluster =  data\$clusters, 'color.[rgb]' =  data\$colors ),\n"
	  . "		file='Sample_Colors.xls' , row.names=F, sep='\t',quote=F )\n";

	open( RSCRIPT, ">$path/RScript.R" )
	  or
	  Carp::confess("I could not create the R script '$path/RScript.R'\n$!\n");
	print RSCRIPT $script;
	close(RSCRIPT);
	chdir($path);

	system(
'/bin/bash -c "DISPLAY=:7 R CMD BATCH --no-save --no-restore --no-readline -- RScript.R > R.run.log"'
	);
	system ( "cp RScript.R $id"."_RScript.R" );
	$id ++;

}

sub run_R_preprocess {
	my $dataset = shift;

	my $script =
	    "source('$Rlib_path"
	  . "Tool_Pipe.R')\n"
	  . "source('$Rlib_path"
	  . "Tool_Plot.R')\n"
	  . "negContrGenes <- NULL\n";
	$script .=
	  "negContrGenes <- c ( '"
	  . join( "', '", @{ $dataset->{'negControllGenes'} } ) . "')\n"
	  if ( defined @{ $dataset->{'negControllGenes'} }[0] );
	$script .=
	    "data.filtered <- createDataObj ( PCR= c( '"
	  . join( "', '", @{ $dataset->{'PCRTable'} } ) . "' ), "
	  . "FACS= c( '"
	  . join( "','", @{ $dataset->{'facsTable'} } ) . "' ), "
	  . "ref.genes= c( '"
	  . join( "', '", @{ $dataset->{'controlM'} } ) . "' ),"
	  . "max.value=40, max.ct= $dataset->{'maxCT'} , max.control=$dataset->{'maxGenes'}, "
	  . " use_pass_fail = '$dataset->{'use_pass_fail'}', "
	  . "  norm.function='$dataset->{'normalize2'}', negContrGenes=negContrGenes )\n"
	  . "save( data.filtered, file='../norm_data.RData' )\n";
	$script =~ s/c\( '.?.?\/?' \)/NULL/g;

	open( RSCRIPT, ">$path/preprocess/Preprocess.R" )
	  or Carp::confess(
		"I could not create the R script '$path/preprocess/Preprocess.R'\n$!\n"
	  );
	print RSCRIPT $script;
	chdir( $path . "/preprocess/" );
	system(
'/bin/bash -c "DISPLAY=:7 R CMD BATCH --no-readline -- Preprocess.R > R.pre.run.log"'
	);

}

