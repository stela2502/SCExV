package HTpcrA::Controller::analyse;
use stefans_libs::flexible_data_structures::data_table;
use HTpcrA::EnableFiles;
use Moose;
use namespace::autoclean;

with 'HTpcrA::EnableFiles';

#BEGIN { extends 'HTpcrA::base_db_controler';};
BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

HTpcrA::Controller::analyse - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

sub update_form {
	my ( $self, $c, $dataset ) = @_;
	my $hash = $self->config_file( $c, 'rscript.Configs.txt' );
	$c->form->name('master');
	$self->{'form_array'} = [];
	$hash = $self->defined_or_set_to_default( $hash, $self->init_dataset() );
	
	push(
		@{ $self->{'form_array'} },
		{
			'comment'  => 'Automatic Re-Order',
			'name'     => 'automaticReorder',
			'options'  =>  { '0' => 'No', '1' => 'Yes' },
			'value'    => $hash->{'automaticReorder'} || 1,
			'required' => 1,
		}
	);		
	push(
		@{ $self->{'form_array'} },
		{
			'comment'  => 'Cluster samples based on',
			'name'     => 'cluster_on',
			'options'  => [ 'Data values', 'MDS' ],
			'value'    => $hash->{'cluster_on'},
			'required' => 1,
		}
	);
	push(
		@{ $self->{'form_array'} },
		{
			'comment' => 'Create svg figures',
			'name'    => 'plotsvg',
			'options' => { '0' => 'No', '1' => 'Yes' },
			'value' => $hash->{'plotsvg'} ||= 0,
			'required' => 1,
		}
	);
	push(
		@{ $self->{'form_array'} },
		{
			'comment' => 'plot type',
			'name'    => 'use_beans',
			'options' => { '0' => 'vioplot', '1' => 'beanplot' },
			'value' => $hash->{'use_beans'} ||= 1,
			'required' => 1,
		}
	);
	push(
		@{ $self->{'form_array'} },
		{
			'comment' => 'plot data',
			'name'    => 'zscoredVioplot',
			'options' => { '0' => 'ct', '1' => 'z scored' },
			'value' => $hash->{'zscoredVioplot'} ||= 1,
			'required' => 1,
		}
	);
	push(
		@{ $self->{'form_array'} },
		{
			'comment' => 'set not expressed value to min expression value -1',
			'name'    => 'move_neg',
			'options' => { '0' => 'No', '1' => 'Yes' },
			'value' => $hash->{'move_neg'} ||= 1,
			'required' => 1,
		}
	);
	push(
		@{ $self->{'form_array'} },
		{
			'comment' => 'plot non-expressing cells',
			'name'    => 'plot_neg',
			'options' => { '0' => 'No', '1' => 'Yes' },
			'value' => $hash->{'plot_neg'} ||= 1,
			'required' => 1,
		}
	);
	push(
		@{ $self->{'form_array'} },
		{
			'comment'  => 'Cluster on:',
			'name'     => 'cluster_by',
			'options'  => [ 'Expression', 'FACS' ],
			'value'    => $hash->{'cluster_by'},
			'required' => 1,
		}
	);
	push(
		@{ $self->{'form_array'} },
		{
			'comment' => 'Cluster Algorithm',
			'name'    => 'cluster_alg',
			'options' => [
				"ward.D",  "ward.D2",  "single", "complete",
				"average", "mcquitty", "median", "centroid"
			],
			'value'    => $hash->{'cluster_alg'},
			'required' => 1,
		}
	);
	push(
		@{ $self->{'form_array'} },
		{
			'comment'  => 'Cluster Function',
			'name'     => 'cluster_type',
			'type'     => 'select',
			'options'  => [ 'hierarchical clust', 'kmeans' ],
			'value'    => $hash->{'cluster_type'} ||= 'hierarchical clust',
			'required' => 1,
			'jsclick'  => 'clust_show( )'
		}
	);
	push(
		@{ $self->{'form_array'} },
		{
			'comment' => 'randomForest gene groups',
			'name'    => 'randomForest',
			'value'   => $hash->{'randomForest'} ||= 10,
		}
	);
	push(
		@{ $self->{'form_array'} },
		{
			'comment'  => 'multi dimensional scaling (MDS) Algorithm',
			'name'     => 'mds_alg',
			'options'  => [ 'PCA', 'LLE', 'ISOMAP' ],
			'value'    => $hash->{'mds_alg'},
			'required' => 1,
			'jsclick'  => 'mds_show( )'
		}
	);
	push(
		@{ $self->{'form_array'} },
		{
			'comment'  => 'Number of expected clusters',
			'name'     => 'cluster_amount',
			'value'    => $hash->{'cluster_amount'},
			'type'     => 'text',
			'required' => 1,
		}
	);
	push(
		@{ $self->{'form_array'} },
		{
			'comment'  => 'Number of neighbours</BR> (LLE and ISO only)',
			'name'     => 'K',
			'value'    => $hash->{'K'},
			'type'     => 'text',
			'required' => 1,
		}
	);

	opendir( DIR, $c->session_path() );

	push(
		@{ $self->{'form_array'} },
		{
			'comment' => 'Group by: (optional)',
			'name'    => 'UG',
			'type'    => 'select',
			'options' =>
			  [ 'none', 'Group by plateID', grep( /Grouping/, readdir(DIR) ) ]
			,    ## you will break the R_script changing this text!
			'value'    => $hash->{'UG'},
			'required' => 0,
			'jsclick' =>
			  "form_fun_match( 'master', 'UG', 'randomForest', 'randomForest')",
		}
	);
	closedir(DIR);
	my $type = 'hidden';

	push(
		@{ $self->{'form_array'} },
		{
			'comment'  => 'x1',
			'name'     => 'x1',
			'type'     => $type,
			'required' => 0,
		}
	);
	push(
		@{ $self->{'form_array'} },
		{
			'comment'  => 'x2',
			'name'     => 'x2',
			'type'     => $type,
			'required' => 0,
		}
	);
	push(
		@{ $self->{'form_array'} },
		{
			'comment'  => 'y1',
			'name'     => 'y1',
			'type'     => $type,
			'required' => 0,
		}
	);
	push(
		@{ $self->{'form_array'} },
		{
			'comment'  => 'y2',
			'name'     => 'y2',
			'type'     => $type,
			'required' => 0,
		}
	);

#$c->stash->{'formNames'} = [map { $_->{'name'} } @{$self->{'form_array'}}[2..(@{$self->{'form_array'}}-1)] ];
	$c->form->method('post');
	foreach ( @{ $self->{'form_array'} } ) {
		$c->form->field( %{$_} );
	}
	$c->form->submit( ['Run Analysis'] );
}

sub fileok : Local : Form {
	my ( $self, $c, $key ) = @_;
	$self->{'form_array'} = [
		{
			'name' => 'key',
			'type' => 'text',
		},
	];
	foreach ( @{ $self->{'form_array'} } ) {
		$c->form->field( %{$_} );
	}
	my $dataset;
	if ( $c->form->submitted && $c->form->validate ) {
		$dataset = $self->__process_returned_form($c);
	}
	elsif ( defined $key ) {
		$dataset->{'key'} = $key;
	}
	if ( defined $dataset->{'key'} ) {
		my $data_table = $self->md5_table( $self->path($c) );
		if (
			defined $data_table->GetAsHash( 'key', 'session_id' )
			->{ $dataset->{'key'} } )
		{
			$c->response->body('OK');
			$c->detach();
		}
		else {
			$c->response->body('FAILED');
			$c->detach();
		}
	}
	$c->stash->{'template'} = 'message.tt2';
}


sub init_dataset {
	return {
		'cluster_amount' => 3,
		'cluster_alg'    => 'ward.D',
		'K'              => 2,
		'cluster_by'     => 'Expression',
		'mds_alg'        => 'PCA',
		'cluster_on'     => 'MDS',
		'UG'             => 'none',
		'randomForest'   => 10,
		'plotsvg'        => 0,
		'zscoredVioplot' => 1,
		'cluster_type'   => 'hierarchical clust',
		'plot_neg'       => 1,
		'move_neg'       => 1,
		'use_beans'      => 1,
	};
}

sub run_first : Local : Form {
	my ( $self, $c, @args ) = @_;
	my $path = $self->path($c);
	$self->check($c,'upload');
	## I need to write the first config file? NO!
	my $dataset =
	  $self->defined_or_set_to_default( { 'UG' => 'Group by plateID' },
		$self->init_dataset() );
	$self->R_script( $c, $dataset );
	my $gg   = $c->model('GeneGroups');
	my $data = $gg->read_data( $path . '2D_data.xls' );
	$gg->read_grouping( $path . "mdsGrouping" )
	  if ( -f $path . "mdsGrouping" );
	$data->plotXY_fixed_Colors(
		$path . "webGL/MDS_2D.png",
		@{ $data->{'Header'} }[ 1, 2 ],
		$data->new( { 'filename' => $path . '2D_data_color.xls' } )
	);

	$self->colors_Hex( $c, $path );

	$c->session->{'first_run'} = 1;

	$c->res->redirect( $c->uri_for("/analyse/index/") );
	$c->detach();
}

sub re_run : Local {
	my ( $self, $c, @args ) = @_;
	my $path = $self->check($c,'upload');
	my $dataset = $self->defined_or_set_to_default( $self->config_file( $c, 'rscript.Configs.txt' ), $self->init_dataset() );
	$args[0] ||= '';
	if ( -f $path . "/" . $args[0] ) {
		$dataset->{'UG'} = $args[0];
		$self->config_file( $c, 'rscript.Configs.txt', $dataset );
	}
	system("rm -Rf $path/*.svg $path/*.png $path/webGL/ $path/R.error");
	$self->R_script( $c, $dataset );
	my $gg   = $c->model('GeneGroups');
	my $data = $gg->read_data( $path . '2D_data.xls' );
	$gg->read_grouping( $path . "mdsGrouping" )
	  if ( -f $path . "mdsGrouping" );
	$data->plotXY_fixed_Colors(
		$path . "webGL/MDS_2D.png",
		@{ $data->{'Header'} }[ 1, 2 ],
		$data->new( { 'filename' => $path . '2D_data_color.xls' } )
	);
	$self->colors_Hex( $c, $path );
	$c->session->{'first_run'} = 1;
	$c->res->redirect( $c->uri_for("/analyse/index/") );
	$c->detach();
}

sub index : Path : Form {
	my ( $self, $c, @args ) = @_;
	my $path = $self->check($c,'upload');
	if ( -f $path . "RandomForest_create_groupings.R" ) {
		chdir($path);
		system(
'/bin/bash -c "DISPLAY=:7 R CMD BATCH --no-save --no-restore --no-readline -- RandomForest_create_groupings.R > R.run.log "'
		);
	}
	$c->stash->{'figure_2d'} =
"<h1> The analysis section</h1>\n<p>Here you can analyse your uploaded data using the options on the left side.</p>";
	$self->update_form($c);
	if ( $c->form->submitted && $c->form->validate ) {

		my $dataset = $self->__process_returned_form($c);
		$dataset->{'randomForest'} ||= 10;
		$self->config_file( $c, 'rscript.Configs.txt', $dataset )
		  ;    # store the analysis options
		$dataset->{'submitButton'} = $c->form->submitted;
		if ( $c->form->submitted() eq "Run Analysis" ) {
			system(
"rm -Rf $path/*.svg $path/*.png $path/webGL/ $path/densityWebGL* $path/R.error"
			);
			my $dataset = $self->__process_returned_form($c);
			$self->R_script( $c, $dataset );
			## now I need to redo the 2D plot in order to be able to subselect the samples based on this plot.
			my $gg   = $c->model('GeneGroups');
			my $data = $gg->read_data( $path . '2D_data.xls' );
			$gg->read_grouping( $path . "mdsGrouping" )
			  if ( -f $path . "mdsGrouping" );

			#Carp::confess ( $data->AsString() );
			$data->plotXY_fixed_Colors(
				$path . "webGL/MDS_2D.png",
				@{ $data->{'Header'} }[ 1, 2 ],
				$data->new( { 'filename' => $path . '2D_data_color.xls' } )
			);
		}
		elsif ( $c->form->submitted() eq "0E0" )
		{    ## remove samples based on the 2D MDS figure!
			if ( $dataset->{'x1'} =~ m/\d+/ ) {
				$self->config_file( $c, 'rscript.Configs.txt', $dataset );
				my $gg   = $c->model('GeneGroups');
				my $data = $gg->read_data( $path . '2D_data.xls' );
				$gg->read_grouping( $path . "mdsGrouping" )
				  if ( -f $path . "mdsGrouping" );

#my $tmp = root::get_hashEntries_as_string( $dataset , 3, "why not remove some samples?? before conversion");
				my ( $xaxis, $yaxis ) =
				  $data->axies( @{ $data->{'header'} }[ 1, 2 ] , GD::Image->new( 10,10) );
				foreach ( 'x1', 'x2' ) {
					$dataset->{$_} =
					  $xaxis->pix2value( $dataset->{$_} * 2 );   ## html scaling
				}
				foreach ( 'y1', 'y2' ) {
					$dataset->{$_} =
					  $yaxis->pix2value( $dataset->{$_} * 2 );   ## html scaling
				}

#Carp::confess ($tmp . root::get_hashEntries_as_string( $dataset , 3, "after conversion"));
				$gg->AddGroup(
					@{ $data->{'header'} }[ 1, 2 ],
					map { $dataset->{$_} } 'x1',
					'x2', 'y2', 'y1'
				);

				## now I need to create a new R script!!!
				my $script =
				    'mark.mds <- read.table( file="'
				  . $path
				  . '2D_data.xls' . '" )' . "\n";

				$script .=
				    "source ('libs/Tool_Plot.R')\n"
				  . "source ('libs/Tool_Pipe.R')\n"
				  . "load( 'norm_data.RData')\n";
				$script .=
				    $gg->export_R_exclude_samples('mark.mds')
				  . "data.filtered <- remove.samples( data.filtered, match(excludeSamples, rownames(data.filtered\$PCR) ) )\n"
				  . "data.filtered <- sd.filter(data.filtered)\n"
				  . "## write the new data\n"
				  . "save( data.filtered, file='norm_data.RData' )\n";
				unlink( $c->session_path() . "R.error" )
				  if ( -f $c->session_path() . "R.error" );
				open( OUT, ">" . $self->path($c) . "ExcludeSamples.R" )
				  or Carp::confess($!);
				print OUT $script;
				close(OUT);
				chdir($path);
				system(
'/bin/bash -c "DISPLAY=:7 R CMD BATCH  --no-save --no-restore --no-readline -- ExcludeSamples.R"'
				);

				$c->res->redirect( $c->uri_for("/analyse/re_run/") );
				$c->detach();
			}
		}
		elsif ( $c->form->submitted() eq "Clear all (ALL!)" ) {
			my $path = $c->session_path();
			chop($path);
			system( 'rm -R ' . $path );
			$c->session->{'PCRTable'}  = undef;
			$c->session->{'facsTable'} = undef;
			$c->res->redirect( $c->uri_for("/files/upload/") );
			$c->detach();
		}
	}
	if ( -d $path . 'webGL' ) {
		my $path = $c->session_path();
		if ( -f $path . "R.error" ) {
			open( IN, "<$path" . "R.error" );
			$c->stash->{'message'} .= join( "", <IN> );
			close(IN);
		}
		$self->slurp_webGL( $c, $self->{'webGL'}, $path );
		$self->slurp_Heatmaps( $c, $path );
		$self->Javascript($c);
		## get all boxplots!
		opendir( DIR, $path );
		$c->stash->{'figure_2d'} = join(
			"",
			$self->create_selector_table_4_figures(
				$c, 'mygallery', 'pictures', 'picture',
				sort grep ( !/_Heatmap.png/, grep ( /\.png/, readdir(DIR) ) )
			)
		);
		closedir(DIR);
		$c->stash->{'figure_2d'} =
		  "<h3>Show expression for </h3>" . $c->stash->{'figure_2d'};
	}
	$c->form->type('TT2');
	$c->form->template( $c->config->{'root'}.'src'. '/form/analysis.tt2' );
	$c->stash->{'template'} = 'analyse.tt2';
}

sub R_script {
	my ( $self, $c, $dataset ) = @_;    #the dataset created from the input form
	$dataset->{'K'} ||= 2;
	$dataset->{'rad'} =~ s/,/./g if ( defined $dataset->{'rad'} );

	if ( $dataset->{'UG'} eq "Group by plateID" ) {
		$c->session->{'gcolors'} = 1;
	}
	else {
		$c->session->{'gcolors'} = 0;
	}

	#$c->session->{'PCRTable'} is an array of filemaps for the PCR files
	if ( @{ $c->session->{'PCRTable'} } == 0 ) {
		$dataset->{'cluster_by'} = 'FACS';
	}
	my $path = $c->session_path();

	## init script
	my $script = $self->_R_source(
		'libs/Tool_Plot.R', 'libs/Tool_Coexpression.R', 'libs/Tool_grouping.R',
		'libs/beanplot_mod/beanplotbeanlines.R', 'libs/beanplot_mod/beanplot.R',
		'libs/beanplot_mod/getgroupsfromarguments.R',
		'libs/beanplot_mod/beanplotinnerborders.R',
		'libs/beanplot_mod/beanplotscatters.R',   'libs/beanplot_mod/makecombinedname.R',
		'libs/beanplot_mod/beanplotpolyshapes.R', 'libs/beanplot_mod/fixcolorvector.R',
		'libs/beanplot_mod/seemslog.R'
	);
	$script .= "load( 'norm_data.RData')\n";
	if ( -f $path . "Gene_grouping.randomForest.txt" ) {
		$script .= "source ('libs/Tool_RandomForest.R')\n"
		  . "load('RandomForestdistRFobject_genes.RData')\n"
		  . "createGeneGroups_randomForest (data.filtered, $dataset->{'randomForest'})\n"
		  . "source ('Gene_grouping.randomForest.txt')\n";
	}
	if ( -f $path . 'userDefGrouping.data'
		&& $dataset->{'UG'} eq "Use my grouping" )
	{
		$script .=
		    "userGroups <- read.table ( file= 'userDefGrouping.data' )\n"
		  . "groups.n <-length (levels(as.factor(userGroups\$groupID) ))\n ";
	}
	elsif ( $dataset->{'UG'} eq "Group by plateID" ) {
		$script .=
		    "userGroups <- data.frame(cellName = rownames(data.filtered\$PCR), groupID = data.filtered\$ArrayID ) \n "
		  . "groups.n <-length (levels(as.factor(userGroups\$groupID) ))\n ";
	}
	elsif ( -f $path . $dataset->{'UG'} ) {    ## an expression based grouping!
		$script .= "source ('$dataset->{'UG'}')\n"
		  . "groups.n <-length (levels(as.factor(userGroups\$groupID) ))\n ";
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
	  . "onwhat='$dataset->{'cluster_by'}'\ndata <- analyse.data ( data.filtered, groups.n=groups.n, "
	  . " onwhat='$dataset->{'cluster_by'}', clusterby='$dataset->{'cluster_on'}', "
	  . "mds.type='$dataset->{'mds_alg'}', cmethod='$dataset->{'cluster_alg'}', LLEK='$dataset->{'K'}', "
	  . " ctype= '$dataset->{'cluster_type'}',  zscoredVioplot = zscoredVioplot"
	  . ", move.neg = move.neg, plot.neg=plot.neg, beanplots=beanplots" . ")\n"
	  . "\nsave( data, file='analysis.RData' )\n\n";

	## now lets identify the most interesting genes:
	$script .=
"GOI <- NULL\ntry( GOI <- get.GOI( data\$z\$PCR, data\$clusters, exclude= -20 ), silent=T)\n"
	  . "if ( ! is.null(data\$PCR) && ! is.null(GOI) ) {\n"
	  . "    rbind( GOI, get.GOI( data\$z\$PCR, data\$clusters, exclude= -20 ) ) \n}\n"
	  . "write.table( GOI, file='GOI.xls' )\n\n";

	$script .=
"write.table( cbind( Samples = rownames(data\$PCR), data\$PCR ), file='merged_data_Table.xls' , row.names=F, sep='\t',quote=F )\n"
	  . "if ( ! is.null(data\$FACS)){\n"
	  . "write.table( cbind( Samples = rownames(data\$FACS), data\$FACS ), file='merged_FACS_Table.xls' , row.names=F, sep='\t',quote=F )\n"
	  . "all.data <- cbind(data\$PCR, data\$FACS )\n"
	  . "write.table(cbind( Samples = rownames(all.data), all.data ), file='merged_data_Table.xls' , row.names=F, sep='\t',quote=F )\n"
	  . "}\n"
	  . "write.table( cbind( Samples = rownames(data\$mds.coord), data\$mds.coord ), file='merged_mdsCoord.xls' , row.names=F, sep='\t',quote=F )\n\n"

	  . "## the lists in one file\n\n"
	  . "write.table( cbind( Samples = rownames(data\$PCR), ArrayID = data\$ArrayID, Cluster =  data\$clusters, 'color.[rgb]' =  data\$colors ),\n"
	  . "		file='Sample_Colors.xls' , row.names=F, sep='\t',quote=F )\n";
	unlink("$path/Summary_Stat_Outfile.xls")
	  if ( -f "$path/Summary_Stat_Outfile.xls" );
	open( RSCRIPT, ">$path/RScript.R" )
	  or
	  Carp::confess("I could not create the R script '$path/RScript.R'\n$!\n");
	print RSCRIPT $script;
	close(RSCRIPT);
	chdir($path);
	$c->model('RandomForest')->RandomForest( $c, $dataset )
	  if ( $c->config->{'randomForest'} );
	system(
'/bin/bash -c "DISPLAY=:7 R CMD BATCH --no-save --no-restore --no-readline -- RScript.R > R.run.log"'
	);
	open( RS2, ">$path/densityWebGL.R" );

	print RS2 "options(rgl.useNULL=TRUE)\n"
	  . "library(ks)\n"
	  . "load( 'clusters.RData' )\n"
	  . "usable <- is.na(match( obj\$clusters, which(table(as.factor(obj\$clusters)) < 4 ) )) == T\n"
	  . "use <- obj\n"
	  . "use\$clusters <- obj\$clusters[usable]\n"
	  . "use\$mds.coord <- obj\$mds.coord[usable,]\n"
	  . "cols <- rainbow(max(as.numeric(obj\$clusters)))\n"
	  . "H <- Hkda( use\$mds.coord, use\$clusters, bw='plugin')\n"
	  . "kda.fhat <- kda( use\$mds.coord, use\$clusters,Hs=H, compute.cont=TRUE)\n"
	  . "try(plot(kda.fhat, cex=par3d('cex'=0.01), colors = cols[as.numeric(names(table(use\$clusters)))] ),silent=F)\n"
	  . "try( writeWebGL(dir = 'densityWebGL', width=470, height=470 ) ,silent=F )\n";

	close(RS2);
	system(
'/bin/bash -c "DISPLAY=:7 R CMD BATCH --no-save --no-restore --no-readline -- densityWebGL.R >> R.run.log"'
	);
	$self->{'webGL'} = "$path/webGL/index.html";
	$self->Coexpression_R_script( $path );
	if ( $dataset->{'UG'} eq "Group by plateID" ) {
		## color the arrays by group color!
		$c->session->{'groupbyplate'} = 1;
	}
	else {
		$c->session->{'groupbyplate'} = 0;
	}

	$c->model('scrapbook')->init( $c->scrapbook() )
	  ->Add("<h3>Analysis RUN</h3>\n<i>options:"
		  . $self->options_to_HTML_table($dataset)
		  . "</i>\n" );
	return "$path/webGL/index.html";

}

sub Coexpression_R_script {
	my ( $self, $path ) =@_;
	## create the corexpression analysis script and start that - do not wait for it to finish!
	## The file should only be available in the downloaded zip file. Hence I probably should wait for it in the download section....
	## first rm the old outfile!!!
	unlink( $path.'Coexpression_4_Cytoscape.txt' ) if ( -f  $path.'Coexpression_4_Cytoscape.txt' );
	## read in the analzed data!
	## call function coexpressGenes( dataObj ) and write the returned table into the previousely deleted file using R
	open ( OUT, ">".$path."Coexpression.R") or Carp::confess( $! );
	print OUT "source('libs/Tool_Coexpression.R')\nload('analysis.RData')\n"
	."t <- coexpressGenes(data)\n"
	."write.table(t,'Coexpression_4_Cytoscape.txt',row.names=F, sep=' ')";
	close ( OUT);
	system(
'/bin/bash -c "DISPLAY=:7 R CMD BATCH --no-save --no-restore --no-readline -- Coexpression.R >> R.run.log" &'
	);
	return 1;
}

sub md5_table {
	my ( $self, $path, $data_table ) = @_;
	my $process_id;
	my $fname = $path . "md5_hashes_randomForests.xls";
	if ( ref($data_table) eq "data_table" ) {
		$process_id = "save file";
		$data_table->write_file($fname);
	}
	else {
		$data_table = data_table->new();
		if ( -f $fname ) {
			$process_id = "read file";
			$data_table->read_file($fname);
		}
		else {
			$process_id = "new file";
			$data_table->Add_2_Header( [ 'filename', 'key', 'session_id' ] );
		}
	}
	return $data_table;
}

sub Javascript {
	my ( $self, $c ) = @_;
	return $self->Script( $c,
		    '<link rel="stylesheet" type="text/css" href="'
		  . $c->uri_for('/css/imgareaselect-default.css') . '" />' . "\n"
		  . '<script type="text/javascript" src="'
		  . $c->uri_for('/scripts/jquery.min.js')
		  . '"></script>' . "\n"
		  . '<script type="text/javascript" src="'
		  . $c->uri_for('/scripts/jquery.imgareaselect.pack.js')
		  . '"></script>' . "\n"
		  . '<script type="text/javascript" src="'
		  . $c->uri_for('/scripts/jquery.bridget.js') . '"'
		  . "></script>\n"
		  . '<script type="text/javascript" src="'
		  . $c->uri_for('/scripts/figures.js')
		  . '"></script>' . "\n"
		  . '<script type="text/javascript" src="'
		  . $c->uri_for('/scripts/analysis_index.js') . '"'
		  . "></script>\n" );
}

sub R_process_data_part {
	my ( $self, $dataset ) = @_;

	## check the FACS data - same sample names??
	my $script .= "if ( exists('facsTable.d') ){
if ( sum(is.na(match(rownames(facsTable.d), rownames(PCRTable.d)))==T) == 0 && nrow(facsTable.d) == nrow(PCRTable.d) ){\n"
	  . "\tfacsTable.d <- facsTable.d[match( rownames(PCRTable.d), rownames(facsTable.d)), ]\n"
	  . "}else {\n"
	  . "\tfacsTable <- NULL\n\trm(facsTable.d)\n"
	  . "\tsystem('echo \"FACS data does not contain the same cells as the PCR data - FACS data ignored!\" > R.error')\n"
	  . "}\n}\n";

	$script .= "cluster.d <- PCRTable.d\n"
	  if ( $dataset->{'cluster_by'} eq 'Expression' );
	$script .=
	    "if ( exists('facsTable.d') ) { \n"
	  . "cluster.d <- facsTable.d\n"
	  . "}else{\ncluster.d <- PCRTable.d\n}\n"
	  if ( $dataset->{'cluster_by'} eq 'FACS' );

	if ( $dataset->{'mds_alg'} eq "PCA" ) {
		$script .= " mark.mds <- prcomp( cluster.d )\$x\n ";
	}
	elsif ( $dataset->{'mds_alg'} eq "LLE" ) {
		$script .=
		  " mark.mds <- LLE( cluster.d, dim = 3, $dataset->{'K'} ) \n ";
	}
	elsif ( $dataset->{'mds_alg'} eq 'ISOMAP' ) {
		$script .=
" mark.mds <- Isomap( cluster.d, dim = 3, $dataset->{'K'} )\$dim3 \n ";
	}
	else {
		Carp::confess(
			"I do not know the cluster_alg option $dataset->{'cluster_alg'}\n"
		);
	}
	$script .= "if ( exists('userGroups') ) {\n"
	  . "pc.clus <- userGroups\$groupID\n}else{\n";
	$script .= "if ( ! exists('pc.clus') ){\n";
	if ( $dataset->{'cluster_on'} eq "MDS" ) {
		$script .=
"pc.clus <-cutree(hclust(dist( mark.mds[,1:3] ),method = \"ward.D\"),k=groups.n)\n";
	}
	elsif ( $dataset->{'cluster_on'} eq "Data values" ) {
		$script .=
"pc.clus <-cutree(hclust(as.dist( 1- cor(t(cluster.d))),method = \"ward.D\"),k=groups.n)\n";
	}
	$script .= "}\n}\n";
	return $script;
}

sub plot_4R {
	my ( $self, $path, $dataset, @names ) = @_;
	my $script = '';
	foreach (@names) {
		$script .=
		    "\nif ( exists('$_.d') ){\nt.$_.d <- t($_.d)\n"
		  . "for ( i in 1:nrow(t.$_.d) ) {\n"
		  . "	png( file=paste('$path',rownames(t.$_.d)[i],'.png',sep=''), width=800,height=800)\n"
		  . "   #create color info\n"
		  . "   lila <- vector('list', groups.n)\n"
		  . "   for( a in 1:groups.n){\n"
		  . "      lila[[a]]=t.$_.d[i,which(pc.clus == a)]\n"
		  . "   }\n"
		  . "   names(lila)[1]= 'x'\n"
		  . "   lila\$col= cols\n"

		  #		  . "   lila\$main =paste('Expression of',rownames(t.$_.d)[i])\n"
		  . "   try( do.call(vioplot,lila), silent=F )\n"

#		  . "   boxplot(t.$_.d[i,]~pc.clus,col=cols,main=paste('Expression of',rownames(t.$_.d)[i],'in the different groups (CT values?)' ))\n"
		  . "dev.off()\n" . "}\n}\n";
	}
	return $script;
}

=head1 AUTHOR

Stefan Lang

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

#__PACKAGE__->meta->make_immutable;

1;
