package HTpcrA::Model::RScript;
use Moose;
use namespace::autoclean;
use File::Copy "mv";
#use Sys::Info;

extends 'Catalyst::Model';

=head1 NAME

HTpcrA::Model::RScript - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.


=encoding utf8

=head1 AUTHOR

Stefan Lang

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

=head2 create_script

This function allows slimmer storage + call of Rscripts.

options: ($path, $file, $script, $wait )

=cut

sub runScript {
	my ( $self, $c, $path, $file, $script, $wait ) = @_;
	unlink( $c->session_path() . "R.error" )
	  if ( -f $c->session_path() . "R.error" );
	open( OUT, ">" . $path . $file ) or Carp::confess($!);
	print OUT $script;
	if ( $script =~ m/norm_data.RData/ ) {
		print OUT "\nrelease.lock( 'norm_data.RData') \n";
	}
	close(OUT);
	$wait ||= '';
	if ( $wait eq 'NoRun' ) {
		return 1;
	}
	if ($wait) {
		$wait = '';
	}
	else {
		$wait = '&';
	}
	chdir($path);
	system(
'/bin/bash -c "DISPLAY=:7 R CMD BATCH --no-save --no-restore --no-readline -- '.$file
		  . " $wait\"" );
	return 1;
}

sub create_script {
	my ( $self, $c, $function, $dataset ) = @_;
	my $str = join( "\n",
		"options(rgl.useNULL=TRUE)", "library(Rscexv)", "useGrouping<-NULL", );
	if ( defined $function ) {
		unless ( $self->can($function) ) {
			Carp::confess(
"Internal server error: R creation function '$function' not defined!\n"
			);
		}
		$str .= "\n" . &{ \&{$function} }( $self, $c, $dataset );
	}
	return $str;
}

sub _add_fileRead {
	my ( $self, $path, $lock ) = @_;
	my $str;
	$lock = 1 unless ( defined $lock);
	unless ( -f $path ){
		$path .= "/" unless ( $path=~m!/$!);
	}
	if ( -f $path . "analysis.RData" ) {
		$str= "'analysis.RData'";
	}
	elsif ( -f $path . "norm_data.RData" ) {
		$str = "'norm_data.RData'";
		$lock = 0;
	}
	unless ( defined ($str)) {
		if ( -f $path."Error_system_message.txt" ) {
			open ( OUT, ">>".$path."Error_system_message.txt");
		}else {
			open ( OUT, ">".$path."Error_system_message.txt");
		}
		print OUT 'probably a problem : no expected .RData file existst in path "' . $path . '"'
	  . "\n";
	  	close ( OUT );
	}
	if ( $lock ) {
		$str = "while ( locked( $str ) ){Sys.sleep(5)}\n"
			. "set.lock ( $str, 'RScript.pm - $lock' )\n"
			. "load( $str )\n";
	}else {
		$str = "load( $str )\n";
	}
	
	return $str;
}


=head2 pValues

Calulate all p values for the data

=cut

sub pValues {
	my ( $self, $c, $dataset ) = @_;
	my $path = $c->session->{'path'};

	$dataset->{'boot'} ||= 1000,
	  $dataset->{'lin_lang_file'} ||= 'lin_lang_stats.xls';
	$dataset->{'sca_ofile'} ||= "Significant_genes.csv";
	my $script =
		$self->_add_fileRead( $c->session_path(), 'pValues' )
	  . "stat_obj <- create_p_values( data, boot = $dataset->{'boot'}, "
	  . "lin_lang_file= '$dataset->{'lin_lang_file'}', sca_ofile ='$dataset->{'sca_ofile'}' )\n"
	  . "saveObj( data )\n"
	  . "release.lock( 'analysis.RData')\n";
	return $script;
}

=head2 geneGroup2D

This creates th R script from the grouping_2d controller.
This is dependant on the GeneGroups class that is provided in the dataset->{'gg'} object.

=cut

sub geneGroup2D {
	my ( $self, $c, $dataset ) = @_;

	my $script = $self->_add_fileRead( $c->session_path(), 'geneGroup2D' );
	$script .= $dataset->{'gg'}->export_R( 'data', $dataset->{'groupname'} );
	$script .= "saveObj(data)\n"
	  . "release.lock( 'analysis.RData')\n";

	return $script;
}

=head2 geneGroup1D_backend

This R script creates all figures for the web frontend 1D gene grouping

=cut

sub geneGroup1D_backend {
	my ( $self, $c, $dataset ) = @_;
	my $script = $self->_add_fileRead( $dataset->{'path'} . "../", 0 );

	## load the previousely defined cut regions
	opendir( DIR, $dataset->{'path'} );
	$script .=
	    "cuts <- list()\n" 
	  . "files <- c( '"
	  . join( "', '",
		map { $dataset->{'subpath'} . "/$_" } grep /.cut$/,
		readdir(DIR) )
	  . "' )\n";
	closedir(DIR);
	$script .=
	    "library(stringr)\n"
	  . "for ( i in 1:length(files)){\n"
	  . "  cuts[[i]] <-readLines( files[i] )\n" . "}\n"
	  . "names(cuts) <- str_replace_all( files, '.cut', '' )\n"
	  . "names(cuts) <- str_replace_all( names(cuts), '$dataset->{'subpath'}/', '' )\n";

	## plot all the expression as histogram
	$script .=
	  "plot.histograms ( data, cuts, subpath='$dataset->{'subpath'}' )\n";

	$script .=
	    "## export all gene names for the web frontend\n"
	  . "n <- rownames(data\@data )\n"
	  . "if ( data\@wFACS ) {\n"
	  . "  n <- c( n , colnames(data\@facs) )\n}\n"
	  . "write( n, file.path( data\@outpath, '$dataset->{'subpath'}', 'Genes.txt'), ncolumns=1 ) \n";
	return $script;
}

=head2 geneGroup1D

This creates a grouping script for a 1D gene group used in the analysis section!

=cut

sub geneGroup1D {
	my ( $self, $c, $dataset ) = @_;

	my @values = sort { $a <=> $b } split( /\s+/, $dataset->{'cutoff'} );
	## store these values for later??
	open( OUT, ">" . $dataset->{'path'} . "$dataset->{GOI}.cut" );
	print OUT join( "\n", @values );
	close(OUT);
	my $script =
	    $self->_add_fileRead( $dataset->{'path'} . "../" , 'geneGroup1D')
	  . "data <- group_1D (data, '$dataset->{'GOI'}', c("
	  . join( ", ", @values )
	  . " ) )\n"
	  . "saveObj( data )\n"
	  . "release.lock( 'analysis.RData')\n";
	return $script;
}

=head2 remove_samples

This function is called from the DropGenes contoller

=cut

sub remove_samples {
	my ( $self, $c, $dataset ) = @_;
	my $path   = $c->session_path();
	my $script = $self->_add_fileRead($path, 'remove_samples');

#Carp::confess ("These are the keys - do we have a 'Samples' one?: ". join(", ", keys %$dataset));
	if ( defined @{ $dataset->{'Samples'} }[0] ) {
		$script .=
		    "remS <- c ('"
		  . join( "', '", @{ $dataset->{'Samples'} } )
		  . "')\ndata = remove.samples(data, match( remS,rownames(data\@data)) )\n"
		  if ( @{ $dataset->{'Samples'} }[0] =~ m/[\w\d_]+/ );
	}
	if ( defined $dataset->{'RegExp'} ) {
		$script .=
"data = remove.samples(data, grep( \"$dataset->{'RegExp'}\" ,rownames(data\@data)) )\n"
		  if ( $dataset->{'RegExp'} =~ m/[\w\d_]+/ );
	}

	$script .=
	    "data <- sd.filter(data)\n"
	  . "data <- z.score.PCR.mad(data)\n"
	  . "saveObj( data )\n"
	  . "release.lock( 'analysis.RData')\n";

	return $script;
}

=head2 regroup

Creates the script to re-order a grouping. Called by the Regroup controller.

=cut

sub regroup {
	my ( $self, $c, $dataset ) = @_;

	my $path    = $c->session_path();
	my $Rscript = $self->_add_fileRead($path, 'regroup');

	my $data_table =
	  data_table->new( { 'filename' => $path . 'Sample_Colors.xls' } );
	my ( $old_ids, $OK );
	## R dataset: group2sample = list ( '1' = c( 'Sample1', 'Sample2' ) )
	$Rscript .= "userGroups <-regroup ( data, list (";
	$OK = 0;
	for ( my $i = 1 ; $i <= scalar( keys %$dataset ) ; $i++ )
	{    ## scale from 1 to n
		next unless ( defined $dataset->{ 'g' . $i } );
		$old_ids = { map { $_ => 1 } $dataset->{ 'g' . $i } =~ m/Group(\d+)/g };
		next if ( keys %$old_ids == 0 );
		$OK++;
		$Rscript .= " \n\t'$i' = c('" . join(
			"', '",
			@{
				$data_table->select_where(
					'grouping',
					sub {
						my $v = shift;
						return 1 if ( $old_ids->{$v} );
						return 0;
					}
				  )->GetAsArray('SampleName')
			  }
		) . "'),";
	}
	if ( $OK < 2 ) {
		$c->stash->{'ERROR'} = [
'Sorry - you have not created enough groups! Min 2 groups are required!'
		];
	}
	chop($Rscript);
	$Rscript .=
	  " )\n, name='$dataset->{GroupingName}')\n" . "saveObj(userGroups)\n"
	  . "release.lock( 'analysis.RData')\n";

	return $Rscript;

}

=head2 recolor

Here I get group 1 to n and have to change the color of the existing color sheme to the required color.

=cut

sub recolor {
	my ( $self, $c, $dataset ) = @_;
	my $path = $c->session_path();

	my $Rscript = $self->_add_fileRead($path, 'recolor');

	$Rscript .=
"if ( is.null( data\@usedObj\$colorRange)) {data\@usedObj\$colorRange <- list() }\nnewCol = c(";
	foreach ( 1 .. $dataset->{'groups'} ) {
		$Rscript .= " '" . $dataset->{"g$_"} . "',";
	}
	chop($Rscript);
	$Rscript .= " )\n";
	$dataset->{'UG'} = $c->usedSampleGrouping();

	$Rscript .= "data\@usedObj\$colorRange[['$dataset->{UG}']] = newCol\n"
	  . "saveObj( data )\n"
	  . "release.lock( 'analysis.RData')\n";

	return $Rscript;
}

=head2 run_RF_local 

Calculates the random forest clusters on the local computer. NOT recommended for a production server!

=cut

sub run_RF_local {
	my ( $self, $c, $dataset ) = @_;
	my $path    = $c->session_path();
	my $Rscript = $self->_add_fileRead($path, 'run_RF_local');

	#my $info = Sys::Info->new;
	#my $cpu = $info->device( CPU => {} );
	#$cpu = $cpu->count || 1;
	my $cpu = 2;

	my $cmd =
	    "data <- rfCluster(data, rep = 1, SGE = F, email='none\@nowhere.de', "
	  . " subset = subset, k = $dataset->{'k'}, nforest = $dataset->{'Number of Forests'},"
	  . " ntree = $dataset->{'Number of Trees'},"
	  . " slice = $cpu )";
	$Rscript .=
	    "subset = $dataset->{'Number of Used Cells'}\n"
	  . "if ( subset + 20 > nrow(data\@data)) {subset = nrow(data\@data) - 20}\n"
	  . "$cmd\n"
	  . "saveObj(data)\n" ## to make this process a little more error prone!
	  . "run = 1\n"
	  . "while ( run ) {\n"
	  . "   try( { $cmd } )\n"
	  . "   if ( length(data\@usedObj\$rfObj[['Rscexv_RFclust_1']]\@distRF) != 0 ) {\n"
	  . "      run = 0\n"
	  . "   }\n"
	  . "   else {\n"
	  . "      Sys.sleep(20)\n"
	  . "   }\n" . "}\n"
	  . $self->_add_fileRead($path)
	  . "$cmd\n"
	  . "saveObj( data )\n"
	  . "release.lock( 'analysis.RData')\n";

	return $Rscript;
}

=head2 recluster_RF_data 

Reuse the rf distribution to create a new grouping.

=cut

sub recluster_RF_data {
	my ( $self, $c, $dataset ) = @_;
	my $path    = $c->session_path();
	my $Rscript = $self->_add_fileRead($path, 'recluster_RF_data');
	$Rscript .=
	    "data <- createRFgrouping_samples( data, "
	  . "RFname = 'Rscexv_RFclust_1', k=$dataset->{'k'}, single_res_col='$dataset->{'Group Name'}' )\n"
	  . "saveObj(data)\n"
	  . "release.lock( 'analysis.RData')\n";
	return $Rscript;
}

=head2 geneorder

Allow the user to reorder the genes the way he wants.

=cut

sub geneorder {
	my ( $self, $c, $dataset ) = @_;
	my $path = $c->session_path();

	my $Rscript = $self->_add_fileRead($path, 'geneorder');

	$Rscript .=
"data\@annotation\$'$dataset->{'GroupingName'}' = factor(data\@annotation[,1], levels= c( '"
	  . join( "', '", @{ $dataset->{gOrder} } ) . "'))\n"
	  . "saveObj(data)\n"
	  . "release.lock( 'analysis.RData')\n";

	return $Rscript;
}

=head2 genegrouping

Allow the user to define a own gene grouping.

=cut

sub genegrouping {
	my ( $self, $c, $dataset ) = @_;
	my $path = $c->session_path();

	my $Rscript = $self->_add_fileRead($path, 'genegrouping');

	$Rscript .= "group <- rep( 0 ,nrow(data\@annotation))\n";
	my $i = 1;
	foreach ( @{ $dataset->{'GeneGroup[]'} } ) {
		$Rscript .=
		    "group[match( c('"
		  . join( "', '", split( /\s+/, $_ ) )
		  . "'), data\@annotation[,1])] = "
		  . $i++ . "\n";
	}
	$Rscript .= "data\@annotation\$'$dataset->{'GroupingName'}' = group\n"
	  . "saveObj(data)\n"
	  . "release.lock( 'analysis.RData')\n";

	return $Rscript;
}

=head2 userGroups

Create a grouping based on user input pattern match. Called from the Regroups controller.
=cut

sub userGroups {
	my ( $self, $c, $dataset ) = @_;
	my $path = $c->session_path();

	unlink( $path . "Grouping_R_Error.txt" )
	  if ( -f $path . "Grouping_R_Error.txt" );

	my @groupsnames = split( /\s+/, $dataset->{'Group Names'} );
	my $data_table =
	  data_table->new( { 'filename' => $path . 'Sample_Colors.xls' } );

	my $Rscript = $self->_add_fileRead($path, 'userGroups');

	$Rscript .=
	    "data <-group_on_strings ( data, c( '"
	  . join( "', '", @groupsnames )
	  . "' ) , name = '$dataset->{'GroupingName'}' )\n"
	  . "saveObj( data)\n"
	  . "release.lock( 'analysis.RData')\n";
	return $Rscript;
}

=head2 fixPath

This short R script fixes the path in an uploaded zip file R object!

=cut

sub fixPath {
	my ( $self, $c, $dataset ) = @_;
	my $path   = $c->session_path();
	my $script = $self->_add_fileRead($path, 'fixPath');
	$script .=
	  "data\@outpath <- pwd()\n" . "saveObj( data )\n". "release.lock( 'analysis.RData')\n";
	return $script;
}

=head2 remove_genes

This function is called from the DropGenes contoller

=cut

sub remove_genes {
	my ( $self, $c, $dataset ) = @_;
	my $path   = $c->session_path();
	my $script = $self->_add_fileRead($path, 'remove_genes');

	if ( defined @{ $dataset->{'Genes'} }[0] ) {
		$script .=
		    "remS <- c ('"
		  . join( "', '", @{ $dataset->{'Genes'} } ) . "')\n"
		  . "kill <- match( remS,colnames(data\@data))\n"
		  . "data = remove.genes(data, kill[which(is.na(kill) == F )] )\n"
		  . "kill <- match( remS,colnames(data\@facs))\n"
		  . "data = remove.FACS.genes(data, kill[which(is.na(kill) == F )] )\n"
		  if ( @{ $dataset->{'Genes'} }[0] =~ m/[\w\d_]+/ );
	}

	$script .=
	    "data <- sd.filter(data)\n"
	  . "data <- z.score.PCR.mad(data)\n"
	  . "saveObj( data )\n"
	  . "release.lock( 'analysis.RData')\n";
	return $script;
}

=head2 densityPlot

This script calculates the density 3D plot for the analysis page.

=cut

sub densityPlot {
	my ( $self, $c, $dataset ) = @_;
	my $path = $c->session_path();

	#	my $script = $self->file_load($c, $dataset);
	my $script = $self->_add_fileRead($path, 0);
	$script .= "library(ks)\n";
	$script .= "plotDensity(data)\n";
	return $script;
}

=head2 coexpression

Creates the body of the coexpression script, that can be run without waiting for it.

=cut

sub coexpression {
	my ( $self, $c, $dataset ) = @_;
	my $path = $c->session_path();
	return
	    $self->_add_fileRead($path,0)
	  . "t <- coexpressGenes(data)\n"
	  . "write.table(t,'Coexpression_4_Cytoscape.txt',row.names=F, sep=' ')\n";
}

=head2 RandomForest

Creates the initial RFcluster script - no bells no whistles.

=cut

sub RandomForest {
	my ( $self, $c, $dataset ) = @_;
	my $path = $c->session_path();
	return
	    $self->_add_fileRead($path, 'RandomForest')
	  . "data <- rfCluster(data,rep=1, SGE=F, email, k= $dataset->{'cluster_amount'},"
	  . " slice=4, subset=nrow(data\@data}-20, pics=F ,nforest=500, ntree=500, name='RFclust', recover=F)\n"
	  . "write.table(t,'Coexpression_4_Cytoscape.txt',row.names=F, sep=' ')\n"
	  . "saveObj( data )\n"
	  . "release.lock( 'analysis.RData')\n";
}

=head2 analyze

Creates the body of the analysis script.

=cut

sub analyze {
	my ( $self, $c, $dataset ) = @_;
	my $path   = $c->session_path();
	my $script = $self->_add_fileRead($path, 'analyze');

	if ( $dataset->{'UG'} eq "Group by plateID" ) {
		$script .= "groups.n <- max( as.numeric(data\@samples[,'ArrayID']))\n"
		  . "useGrouping <- 'ArrayID'\n";
	}
	elsif ( $dataset->{'UG'} eq "none" ) {
		$script .= "groups.n <- $dataset->{'cluster_amount'}\n";
	}
	elsif ( $dataset->{'UG'} =~ m/\w/ ) {    ## an expression based grouping!
		$script .= "useGrouping <-  '$dataset->{'UG'}'\n"
		  . "groups.n <- max( as.numeric(data\@samples[,useGrouping]))\n ";
	}
	else {
		$script .= "groups.n <-$dataset->{'cluster_amount'}\n";
	}
	if ( $dataset->{'move_neg'} ) {
		$script .= "move.neg <- TRUE\n";
	}
	else {
		$script .= "move.neg <- FALSE\n";
	}
	if ( $dataset->{'plot_neg'} ) {
		$script .= "plot.neg <- TRUE\n";
	}
	else {
		$script .= "plot.neg <- FALSE\n";
	}
	if ( $dataset->{'use_beans'} ) {
		$script .= "beanplots = TRUE\n";
	}
	else {
		$script .= "beanplots = FALSE\n";
	}
	if ( $dataset->{'GeneUG'} eq "none" or $dataset->{'GeneUG'} eq "" ) {
		$dataset->{'GeneUG'} = '';
	}
	else {
		$dataset->{'GeneUG'} = ", geneGroups = '$dataset->{'GeneUG'}'";
	}

	$script .=
	    "plotsvg = $dataset->{'plotsvg'}\n"
	  . "zscoredVioplot = $dataset->{'zscoredVioplot'}\n"
	  . "onwhat='$dataset->{'cluster_by'}'\n"
	  . "data <- analyse.data ( data, groups.n=groups.n, "
	  . "onwhat='$dataset->{'cluster_by'}', clusterby='$dataset->{'cluster_on'}', "
	  . "mds.type='$dataset->{'mds_alg'}', cmethod='$dataset->{'cluster_alg'}', LLEK='$dataset->{'K'}', "
	  . "ctype= '$dataset->{'cluster_type'}',  zscoredVioplot = zscoredVioplot"
	  . ", move.neg = move.neg, plot.neg=plot.neg, beanplots=beanplots, plotsvg =plotsvg, useGrouping=useGrouping $dataset->{'GeneUG'})\n"
	  . "\n"
	  . "saveObj( data )\n"
	  . "release.lock( 'analysis.RData')\n";

	unlink("$path/Summary_Stat_Outfile.xls")
	  if ( -f "$path/Summary_Stat_Outfile.xls" );
	return $script;
}

=header2
file_load will create the script used for the file upload.
=cut

sub file_load {
	my ( $self, $c, $dataset ) = @_;
	my $seesion_hash = $c->session();
	my $path         = $c->session_path();
	if ( -f $path . "/analysis.RData" ) {
		mv( $path . "/analysis.RData", $path . "/analysis.old.RData" );
	}
	my $script = "negContrGenes <- NULL\n";
	$script .=
	  "negContrGenes <- c ( '"
	  . join( "', '", @{ $dataset->{'negControllGenes'} } ) . "')\n"
	  if ( defined @{ $dataset->{'negControllGenes'} }[0]
		and !@{ $dataset->{'negControllGenes'} }[0] eq "linux" );
	$dataset->{'controlM'} ||= [];
	$script .= "data <- createDataObj ( PCR= c( "
	  . join( ", ",
		map { "'$_->{'filename'}'" } @{ $seesion_hash->{'PCRTable'} } )
	  . " ), "
	  . "FACS= c( "
	  . join( ", ",
		map { "'$_->{'filename'}'" } @{ $seesion_hash->{'facsTable'} } )
	  . " ), "
	  . "ref.genes= c( '"
	  . join( "', '", @{ $dataset->{'controlM'} } ) . "' ),"
	  . " use_pass_fail = '$dataset->{'use_pass_fail'}', "
	  . "max.value=40, max.ct= $dataset->{'maxCT'} , max.control=$dataset->{'maxGenes'}, "
	  . "norm.function='$dataset->{'normalize2'}', negContrGenes=negContrGenes )\n"
	  . "saveObj( data, file='norm_data.RData' )\n"
	  . "release.lock( 'norm_data.RData')\n";
	$script =~ s/c\( '.?.?\/?' \)/NULL/g;
	return $script;
}

__PACKAGE__->meta->make_immutable;

1;
