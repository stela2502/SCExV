#! /usr/bin/perl -d:NYTProf
use strict;
use warnings;
use Test::More tests => 30;
use stefans_libs::flexible_data_structures::data_table;

use FindBin;
my $plugin_path = "$FindBin::Bin";
my $path = $plugin_path."/data/Output/R_run/";
my $Rlib_path = $plugin_path."/../root/R_lib/";
mkdir ( $path."preprocess/" ) unless ( -d  $path."preprocess/" );

my $use_Fail_Pass = 1;

system ("rm $path* $path"."preprocess/*" );

my @source_files = ( $path."preprocess/Plate1.csv", $path."preprocess/Plate2.csv", $path."preprocess/Plate3.csv", $path."preprocess/Plate4.csv" );

my $plate1 = &create_file($path."preprocess/Plate1.csv", 2.1,0 );
my $plate2 = &create_file($path."preprocess/Plate2.csv", 3.2,1 );
my $plate3 = &create_file($path."preprocess/Plate3.csv", 1.3,2 );
my $plate4 = &create_file($path."preprocess/Plate4.csv", 4.4,3 );

my $contr_hash = {
	'negControllGenes' => [],
	'PCRTable' => [@source_files],
	'PCRTable2' => [],
	'facsTable' => [],
	'controlM' => [], ##control genes
	'maxCT' => 40,
	'maxGenes' => 0, ## how manny control genes may fail before the sample is excluded
	                 ## 'any', 'more than 1', 'more than 2', 'all 4' 
	'use_pass_fail' => 'T',
	'normalize2' => 'none', # one of 'max expression', 'mean control genes', 'quantile', 'none'
	'negControllGenes' => [], ## the negaive control genes - expression in the gene removes the sample
};


&run_R_preprocess($contr_hash);
foreach ( "GeneB.png", "GeneC1.png", "GeneC2.png", "boxplot_filtered_samples.svg" , qw(GeneD.png GeneF.png GeneH.png ) ){
	ok (-f  $path."preprocess/$_",  "preprocess produced file $_" );
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

&run_R_analysis($analysis_hash);

my $data_table = data_table->new( {'filename' => $path."merged_data_Table.xls"} );
ok ($data_table->Rows() == 16, "rows merged_data_Table.xls" );
ok ($data_table->Columns() == 7, "cols merged_data_Table.xls" );


is_deeply ( $data_table->select_where('Samples', sub{ return shift =~ m/P0$/ })->{'data'}, $plate1->{'data'}, "4x1 Plate 1 read as expected" );
is_deeply ( $data_table->select_where('Samples', sub{ return shift =~ m/P1$/ })->{'data'}, $plate2->{'data'}, "4x1 Plate 2 read as expected" );
is_deeply ( $data_table->select_where('Samples', sub{ return shift =~ m/P2$/ })->{'data'}, $plate3->{'data'}, "4x1 Plate 3 read as expected" );
is_deeply ( $data_table->select_where('Samples', sub{ return shift =~ m/P3$/ })->{'data'}, $plate4->{'data'}, "4x1 Plate 4 read as expected" );

$plate3 = &create_file($path."preprocess/Plate3.csv", 1.3,2 , ' Plate X');
$plate4 = &create_file($path."preprocess/Plate4.csv", 4.4,3, ' Plate X' );

&run_R_preprocess($contr_hash);
foreach ( "GeneB.png", "GeneC1.png", "GeneC2.png", "boxplot_filtered_samples.svg" , qw(GeneD.png GeneF.png GeneH.png ) ){
	ok (-f  $path."preprocess/$_",  "preprocess produced file $_" );
}

$contr_hash = {
	'negControllGenes' => [],
	'PCRTable' => [@source_files[2,3]],
	'PCRTable2' => [],
	'facsTable' => [@source_files[0,1]],
	'controlM' => [], ##control genes
	'maxCT' => 40,
	'maxGenes' => 0, ## how manny control genes may fail before the sample is excluded
	                 ## 'any', 'more than 1', 'more than 2', 'all 4' 
	'use_pass_fail' => 'T',
	'normalize2' => 'none', # one of 'max expression', 'mean control genes', 'quantile', 'none'
	'negControllGenes' => [], ## the negaive control genes - expression in the gene removes the sample
};

&run_R_preprocess($contr_hash);
foreach ( "GeneB.png", "GeneC1.png", "GeneC2.png", "GeneA Plate X.png", "boxplot_filtered_samples.svg" , qw(GeneD.png GeneF.png GeneH.png ) ){
	ok (-f  $path."preprocess/$_",  "preprocess produced file $_" );
}

&run_R_analysis($analysis_hash);

$data_table = data_table->new( {'filename' => $path."merged_data_Table.xls"} );

ok ($data_table->Rows() == 8, "rows merged_data_Table.xls" );
ok ($data_table->Columns() == 15, "cols merged_data_Table.xls ". $data_table->Columns()." == 15" );

#print $data_table->AsString();

#system ( "cat $path/preprocess/Preprocess.Rout" );

sub create_file{
	my ( $filename, $start, $id, $add ) = @_;
	$start = 1 if ( $start > 7 );
	$add ||= '';
	my $str = "Chip Run Info,C:\\SomePathToTheFiles\\ChipRun.bml,1361995085,96.96 (136x),GE 96x96 Fast PCR+Melt v2,ROX,EvaGreen,2014-08-15 14:20:22,00:30:56,BIOMARKHD151
Application Version,4.1.2
Application Build,20140110.1735
Export Type,Table Results
Quality Threshold,0.65
Baseline Correction Method,Linear (Derivative)
Ct Threshold Method,Auto (Global)


Experiment Information,Experiment Information,Experiment Information,Experiment Information,Experiment Information,Experiment Information,EvaGreen,EvaGreen,EvaGreen,EvaGreen,EvaGreen,EvaGreen,EvaGreen,User
Chamber,Sample,Sample,Sample,EvaGreen,EvaGreen,Ct,Ct,Ct,Ct,Tm,Tm,Tm,Defined
ID,Name,Type,rConc,Name,Type,Value,Quality,Call,Threshold,In Range,Out Range,Peak Ratio,Comments
";
	my @samples = map{ $_. $add} qw(A1 A2 A3 A4);
	my @genes = map{ $_. $add} qw(GeneA GeneB GeneC GeneC GeneD GeneF GeneH);
	my $value;
	my $count = 0;
	## GeneA always fails!
	## flui well, sample name, sample id, 1, gene name, Test , VALUE, [01], [Fail Pass], p to be OK, some value, corrected some value or 999, 1..0,
	$value = $start;
	my $clear_table = data_table->new();
	$clear_table -> Add_2_Header( [ 'Samples', 'GeneB', 'GeneC', 'GeneC1', 'GeneD', 'GeneF', 'GeneH' ] );
	foreach my $sample ( @samples ) {
		my @array = ( $sample.".P$id" );
		push(@{$clear_table ->{data}},\@array);
		$count ++;
		foreach my $gene ( @genes ) {
			$value = $start +$count * 0.07 if ( $count % 9 == 0 );
			push ( @array, (40 -$value) ) unless (  $gene eq "GeneA" );
			$str .= "not interesting $gene,$sample,Unknown,1,$gene,Test,".$value.",";
			$value += sprintf( '%.3f', rand(2)) -  sprintf( '%.3f', rand(2));
			if ( $gene eq "GeneA" ) {
				$str .= "0,Fail,0.543,31,999,0.4,\n";
			}
			else {
				$str .= "1,Pass,0.543,31,0.4456456,0.9,\n";
			}
		}
	}
	open ( OUT, ">$filename") or die "$!\n";
	print OUT $str;
	close (OUT );
	return $clear_table; 
}

sub run_R_preprocess {
	my $dataset = shift;
	system ( "rm -R $path/preprocess/*.png $path/preprocess/*.svg" );
	while ( scalar( @{ $dataset->{'PCRTable'} } ) > scalar( @{ $dataset->{'PCRTable2'} }) ) {
		push(@{ $dataset->{'PCRTable2'} }, "../---" );
	}
	my $script = "source('$Rlib_path"."Tool_Pipe.R')\n"."source('$Rlib_path"."Tool_Plot.R')\n"
	. "negContrGenes <- NULL\n";
   $script .= 
	   "negContrGenes <- c ( '".join("', '",@{$dataset->{'negControllGenes'}}). "')\n" if (defined @{$dataset->{'negControllGenes'}}[0]  );
	$script .=    
	  "data.filtered <- createDataObj ( PCR= c( '"
	  . join( "', '", @{ $dataset->{'PCRTable'} } )
	  . "' ), ". " PCR2= c( '"
	  . join( "', '",@{ $dataset->{'PCRTable2'} } )
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
	
	open( RSCRIPT, ">$path/preprocess/Preprocess.R" )
	  or Carp::confess(
		"I could not create the R script '$path/Preprocess.R'\n$!\n");
	print RSCRIPT $script;
	chdir($path."preprocess");
	system(
'/bin/bash -c "DISPLAY=:7 R CMD BATCH --no-readline -- Preprocess.R > R.pre.run.log"'
	);
	
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
	  . "write.table( cbind( Samples = rownames(data\$FACS), data\$PCR,  data\$FACS ), file='merged_data_Table.xls' , row.names=F, sep='\t',quote=F )\n"
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

}

