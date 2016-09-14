package HTpcrA::Model::RScript;
use Moose;
use namespace::autoclean;

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
'/bin/bash -c "DISPLAY=:7 R CMD BATCH --no-save --no-restore --no-readline -- '
		  . $file
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
	my ( $self, $path ) = @_;
	if ( -f $path . "analysis.RData" ) {
		return "load('analysis.RData')\ndata.filtered <- data\n";
	}
	if ( -f $path . "norm_data.RData" ) {
		return "load('norm_data.RData')\n";
	}
	return '## probably a problem : no file existst in path "' . $path . '"'
	  . "\n";
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
	    "load('analysis.RData')\n"
	  . "stat_obj <- create_p_values( data, boot = $dataset->{'boot'}, "
	  . "lin_lang_file= '$dataset->{'lin_lang_file'}', sca_ofile ='$dataset->{'sca_ofile'}' )\n"
	  . "saveObj( data, file='analysis.RData' )\n";
	return $script;
}


=head2 geneGroup2D

This creates th R script from the grouping_2d controller.
This is dependant on the GeneGroups class that is provided in the dataset->{'gg'} object.

=cut

sub geneGroup2D {
	my ( $self, $c, $dataset ) = @_;
		
	my $script = $self-> _add_fileRead ( $c->session_path() );
	$script .= $dataset->{'gg'}->export_R(  'data.filtered', $dataset->{'groupname'} );
	$script .= "saveObj(data.filtered)\n";
	
	return $script;
}


=head2 geneGroup1D_backend

This R script creates all figures for the web frontend 1D gene grouping

=cut

sub geneGroup1D_backend {
	my ( $self, $c, $dataset ) = @_;
	my $script = $self->_add_fileRead( $dataset->{'path'} . "../" );

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
"plot.histograms ( data.filtered, cuts, subpath='$dataset->{'subpath'}' )\n";

	$script .=
	    "## export all gene names for the web frontend\n"
	  . "n <- rownames(data.filtered\@data )\n"
	  . "if ( data.filtered\@wFACS ) {\n"
	  . "  n <- c( n , colnames(data.filtered\@facs) )\n}\n"
	  . "write( n, file.path( data.filtered\@outpath, '$dataset->{'subpath'}', 'Genes.txt'), ncolumns=1 ) \n";
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
	    $self->_add_fileRead( $dataset->{'path'} . "../" )
	  . "data <- group_1D (data.filtered, '$dataset->{'GOI'}', c("
	  . join( ", ", @values )
	  . " ) )\n"
	  . "saveObj( data )\n";
	return $script;
}

=head2 remove_samples

This function is called from the DropGenes contoller

=cut

sub remove_samples {
	my ( $self, $c, $dataset ) = @_;
	my $path   = $c->session_path();
	my $script = $self->_add_fileRead( $path );

#Carp::confess ("These are the keys - do we have a 'Samples' one?: ". join(", ", keys %$dataset));
	if ( defined @{ $dataset->{'Samples'} }[0] ) {
		$script .=
		    "remS <- c ('"
		  . join( "', '", @{ $dataset->{'Samples'} } )
		  . "')\ndata.filtered = remove.samples(data.filtered, match( remS,rownames(data.filtered\@data)) )\n"
		  if ( @{ $dataset->{'Samples'} }[0] =~ m/[\w\d_]+/ );
	}
	if ( defined $dataset->{'RegExp'} ) {
		$script .=
"data.filtered = remove.samples(data.filtered, grep( \"$dataset->{'RegExp'}\" ,rownames(data.filtered\@data)) )\n"
		  if ( $dataset->{'RegExp'} =~ m/[\w\d_]+/ );
	}

	$script .=
	    "data.filtered <- sd.filter(data.filtered)\n"
	  . "data <- z.score.PCR.mad(data.filtered)\n"
	  . "save( data, file='analysis.RData' )\n";

	return $script;
}

=head2 remove_genes

This function is called from the DropGenes contoller

=cut

sub remove_genes {
	my ( $self, $c, $dataset ) = @_;
	my $path   = $c->session_path();
	my $script = $self->_add_fileRead($path);
	
	if ( defined @{ $dataset->{'Genes'} }[0] ) {
		$script .=
		    "remS <- c ('"
		  . join( "', '", @{ $dataset->{'Genes'} } ) . "')\n"
		  . "kill <- match( remS,colnames(data.filtered\@data))\n"
		  . "data.filtered = remove.genes(data.filtered, kill[which(is.na(kill) == F )] )\n"
		  . "kill <- match( remS,colnames(data.filtered\@facs))\n"
		  . "data.filtered = remove.FACS.genes(data.filtered, kill[which(is.na(kill) == F )] )\n"
		  if ( @{ $dataset->{'Genes'} }[0] =~ m/[\w\d_]+/ );
	}

	$script .=
	    "data.filtered <- sd.filter(data.filtered)\n"
	  . "data <- z.score.PCR.mad(data.filtered)\n"
	  . "save( data, file='analysis.RData' )\n";
	return $script;
}

=head2 densityPlot

This script calculates the density 3D plot for the analysis page.

=cut

sub densityPlot {
	my ( $self, $c, $dataset ) = @_;
	my $path   = $c->session_path();
#	my $script = $self->file_load($c, $dataset);
	my $script = $self->_add_fileRead($path);
	$script .= "library(ks)\n";
	$script .= "plotDensity(data.filtered)\n";
	return $script;
}

=head2 coexpression

Creates the body of the coexpression script, that can be run without waiting for it.

=cut

sub coexpression {
	my ( $self, $c, $dataset ) = @_;
	my $path = $c->session_path();
	return
	    $self->_add_fileRead($path)
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
	    $self->_add_fileRead($path)
	  . "data <- rfCluster(data,rep=1, SGE=F, email, k= $dataset->{'cluster_amount'},"
	  . " slice=4, subset=nrow(data\@data}-20, pics=F ,nforest=500, ntree=500, name='RFclust', recover=F)\n"
	  . "write.table(t,'Coexpression_4_Cytoscape.txt',row.names=F, sep=' ')\n"
	  ."save( data, file='analysis.RData' )\n";
}

=head2 analyze

Creates the body of the analysis script.

=cut

sub analyze {
	my ( $self, $c, $dataset ) = @_;
	my $path = $c->session_path();
	my $script =
	    $self->_add_fileRead($path);

	if ( -f $path . "Gene_grouping.randomForest.txt" ) {
		Carp::confess(
			"RF Grouping is broken in the developmental version! FIXME!!!");
		$script .=
		    "source ('libs/Tool_RandomForest.R')\n"
		  . "load('RandomForestdistRFobject_genes.RData')\n"
		  . "createGeneGroups_randomForest (data.filtered, $dataset->{'randomForest'})\n"
		  . "source ('Gene_grouping.randomForest.txt')\n";
	}
	if ( $dataset->{'UG'} eq "Group by plateID" ) {
		$script .= "groups.n <- max( as.numeric(data.filtered\@samples[,'ArrayID']))\n"
		  . "useGrouping <- 'ArrayID'\n";
	}
	elsif(  $dataset->{'UG'} eq "none" ) {
		$script .= "groups.n <- $dataset->{'cluster_amount'}\n";
	}
	elsif ( $dataset->{'UG'} =~ m/\w/ ) {    ## an expression based grouping!
		$script .= "useGrouping <-  '$dataset->{'UG'}'\n"
		  . "groups.n <- max( data.filtered\@samples[,useGrouping])\n ";
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
	$script .=
	    "plotsvg = $dataset->{'plotsvg'}\n"
	  . "zscoredVioplot = $dataset->{'zscoredVioplot'}\n"
	  . "onwhat='$dataset->{'cluster_by'}'\n"
	  . "data <- analyse.data ( data.filtered, groups.n=groups.n, "
	  . "onwhat='$dataset->{'cluster_by'}', clusterby='$dataset->{'cluster_on'}', "
	  . "mds.type='$dataset->{'mds_alg'}', cmethod='$dataset->{'cluster_alg'}', LLEK='$dataset->{'K'}', "
	  . "ctype= '$dataset->{'cluster_type'}',  zscoredVioplot = zscoredVioplot"
	  . ", move.neg = move.neg, plot.neg=plot.neg, beanplots=beanplots, plotsvg =plotsvg, useGrouping=useGrouping)\n"
	  . "\n"
	  . " save( data, file='analysis.RData' )\n"
	  . "write.table( cbind(data\@samples[,c(1,2)], 'grouping' = data\@usedObj[['clusters']], colors=data\@usedObj[['colors']]),
					file='Sample_Colors.xls' , row.names=F, sep='\\t',quote=F )\n";

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
	my $script       = "negContrGenes <- NULL\n";
	$script .=
	  "negContrGenes <- c ( '"
	  . join( "', '", @{ $dataset->{'negControllGenes'} } ) . "')\n"
	  if ( defined @{ $dataset->{'negControllGenes'} }[0] );
	$dataset->{'controlM'}  ||=[];
	$script .= "data.filtered <- createDataObj ( PCR= c( "
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
	  . "save( data.filtered, file=file.path(data.filtered\@outpath,'norm_data.RData') )\n";
	$script =~ s/c\( '.?.?\/?' \)/NULL/g;
	return $script;
}

__PACKAGE__->meta->make_immutable;

1;
