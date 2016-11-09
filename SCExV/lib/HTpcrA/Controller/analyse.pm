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
			'comment' => 'Automatic Re-Order',
			'name'    => 'automaticReorder',
			'options' => { '0' => 'No', '1' => 'Yes' },
			'value' => $hash->{'automaticReorder'} || 1,
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
			'options'  => [ 'PCA', 'LLE', 'ISOMAP', 'ZIFA', 'DDRTree' ],
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

	my @grps = $c->all_groupings();
	$hash->{'UG'} =  $grps[0] if ( ! ( $grps[0] eq "none" ) );
	push(
		@{ $self->{'form_array'} },
		{
			'comment' => 'Sample Group by: (optional)',
			'name'    => 'UG',
			'type'    => 'select',
			'options' => [ @grps ]
			,    ## you will break the R_script changing this text!
			'value'    => $hash->{'UG'},
			'required' => 0,
	#		'jsclick' =>
	#		  "form_fun_match( 'master', 'UG', 'randomForest', 'randomForest')",
		}
	);
	
	my @Ggrps = $c->all_groupings( 'GeneGroupings.txt' );
	push(
		@{ $self->{'form_array'} },
		{
			'comment' => 'Gene Group by: (optional)',
			'name'    => 'GeneUG',
			'type'    => 'select',
			'options' => [ @Ggrps ]
			,    ## you will break the R_script changing this text!
			'value'    => $hash->{'GeneUG'},
			'required' => 0,
	#		'jsclick' =>
	#		  "form_fun_match( 'master', 'UG', 'randomForest', 'randomForest')",
		}
	);
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
		'GeneUG'         => 'none',
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
	$self->check( $c, 'upload' );
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
	my $path = $self->check( $c, 'upload' );
	my $dataset =
	  $self->defined_or_set_to_default(
		$self->config_file( $c, 'rscript.Configs.txt' ),
		$self->init_dataset() );
	$args[0] ||= '';
	if ( !($args[0] eq "") ){
		$args[0] =~ s/&nbsp;/ /g;
		my @grps = $c->all_groupings();
		foreach ( @grps ) {
			 if ( $_ eq $args[0] ){
			 	$dataset->{'UG'} = $args[0];
			 	$self->config_file( $c, 'rscript.Configs.txt', $dataset );
			 }
		}
	}
	if ( !($args[1] eq "") ){
		my $available = { map { $_ => 1 } $c->all_groupings( 'GeneGroupings.txt' ) };
		if ( $available->{$args[1]} ) {
			$dataset->{'GeneUG'} = $args[1];
		}
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

sub rfgrouping : Local {
	my ( $self, $c ) = @_;
	my $path = $self->check( $c, 'upload' );

	my %xml_escape_map = (
		'<' => '&lt;',
		'>' => '&gt;',
		'"' => '&quot;',
		'&' => '&amp;',
	);

	opendir( my $dh, $path );
	my @rf_groups = grep { /randomForest/ && -f $path . $_ } readdir($dh);
	closedir $dh;

	# Begin the XML document
	my $xml =
	    '<?xml version="1.0" encoding="utf-8" ?>' . "\n"
	  . "<CHANGED>"
	  . scalar(@rf_groups)
	  . "</CHANGED>\n";
	if ( scalar(@rf_groups) ) {
		$xml .= "<GROUPS type='array'>\n";
		foreach (@rf_groups) {
			$xml .= "<value>$_</value>\n";
		}
		# Terminate the xml
		$xml .= '</GROUPS>' . "\n";
	}
	$c->res->content_type('text/xml');
	$c->res->write($xml);
	$c->res->code(204);
}

sub index : Path : Form {
	my ( $self, $c, @args ) = @_;
	my $path = $self->check( $c, 'upload' );
	if ( -f $path . "rf_submitted.info" && ! (-f $path . "rf_recieved.info" ) ) {
		$c->stash->{'RFsubmitted'} = 1;
	}
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
		warn "Button return value = ". $c->form->submitted."\n";
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
		{    ## this is when the RemoveSamples is pressed in 2D MDS view
			if ( $dataset->{'x1'} =~ m/\d+/ ) {
				$self->config_file( $c, 'rscript.Configs.txt', $dataset );
				my $gg   = $c->model('GeneGroups');
				my $data = $gg->read_data( $path . '2D_data.xls' );
				$gg->read_grouping( $path . "mdsGrouping" )
				  if ( -f $path . "mdsGrouping" );

#my $tmp = root::get_hashEntries_as_string( $dataset , 3, "why not remove some samples?? before conversion");
				my ( $xaxis, $yaxis ) = $data->axies(
					@{ $data->{'header'} }[ 1, 2 ],
					GD::Image->new( 10, 10 )
				);
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
				my $script = $c->model('RScript')->create_script()."\n"
				  .	$c->model('RScript')->_add_fileRead( $path )
				  .  'mark.mds <- read.table( file="'
				  . $path
				  . '2D_data.xls' . '" )' . "\n";

				$script .=
				    $gg->export_R_exclude_samples('mark.mds')
				  . "data <- remove.samples( data, match(excludeSamples, rownames(data\@data) ) )\n"
				  . "data <- sd.filter(data)\n"
				  . "## write the new data\n"
				  . "save( data, file='analysis.RData' )\n";
				
				$c->model('RScript')->runScript( $c, $path, "ExcludeSamples.R", $script );

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
		$self->update_form( $c );
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
	$c->form->template( $c->config->{'root'} . 'src' . '/form/analysis.tt2' );
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
	my $path = $c->session_path();
	#$c->session->{'PCRTable'} is an array of filemaps for the PCR files
	if ( @{ $c->session->{'PCRTable'} } == 0 ) {
		$dataset->{'cluster_by'} = 'FACS';
	}
	
	## init scripts
	my $script = $c->model('RScript')->create_script($c,'analyze',$dataset);
	unlink("$path/Summary_Stat_Outfile.xls")
	  if ( -f "$path/Summary_Stat_Outfile.xls" );
	$c->model('RScript')->runScript( $c, $path, 'RScript.R', $script, "wait" );
	
	$script =  $c->model('RScript')->create_script($c, 'densityPlot', $dataset );

	$c->model('RScript')->runScript( $c, $path, 'densityWebGL.R', $script, "wait" );
	
	$self->{'webGL'} = "$path/webGL/index.html";
	
	$script =  $c->model('RScript')->create_script($c, 'coexpression', $dataset );
	## no wait required, as this is downoadable content anyhow
	$c->model('RScript')->runScript( $c, $path, 'Coexpression.R', $script ); 

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

=head1 AUTHOR

Stefan Lang

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

#__PACKAGE__->meta->make_immutable;

1;
