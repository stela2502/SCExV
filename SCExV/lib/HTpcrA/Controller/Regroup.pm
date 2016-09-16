package HTpcrA::Controller::Regroup;
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


sub samplenames : Local : Form {
	my ( $self, $c, @args ) = @_;
	my $path = $self->check($c);

	$c->form->field(
		'type'     => 'textarea',
		'cols'     => 20,
		'rows'     => 10,
		'id'       => 'Group Names',
		'name'     => 'Group Names',
		'value'    => '',
		'required' => 1,
	);

	$c->form->field(
		'id'       => 'GroupingName',
		'name'     => 'GroupingName',
		'value'    => 'Group_UserInfo',
		'required' => 1,
	);

	if ( $c->form->submitted && $c->form->validate ) {
		## exclude some samples!!
		my $analysis_conf = $self->config_file( $c, 'rscript.Configs.txt' );
		my $dataset = $self->__process_returned_form($c);

		my $Rscript =
		  $c->model('RScript')->create_script( $c, 'userGroups', $dataset );
		$c->model('RScript')
		  ->runScript( $c, $path, "Grouping_" . $dataset->{'GroupingName'},
			$Rscript, 'wait' );

		if ( -f $path . "Grouping_R_Error.txt" ) {
			open( IN, "<$path" . "Grouping_R_Error.txt" );
			$c->stash->{'ERROR'} = [<IN>];
			close(IN);
		}
		else {
			$c->model('scrapbook')->init( $c->scrapbook() )->Add(
				"<h3>Create a user defined grouping</h3>\n<i>options:"
				  . $self->options_to_HTML_table($dataset) . "</i>\n"
			);
			$c->res->redirect(
				$c->uri_for("/analyse/re_run/$dataset->{'GroupingName'}") );
			$c->detach();
		}

	}
	$c->stash->{'template'} = 'SampleNameGroups.tt2';
}

sub reorder : Local : Form {
	my ( $self, $c, @args ) = @_;
	my $path = $self->check($c);

	$self->source_groups($c);
	$self->JavaScript($c);
	$self->{'form_array'} = [];
	foreach ( 1 .. $c->stash->{'groups'} ) {
		$c->form->field(    #HTML defined in $self->source_groups($c)
			'id'       => "g$_",
			'name'     => "g$_",
			'value'    => '',
			'required' => 0,
			'type'     => 'hidden',

		);
	}
	$c->form->field(

		'id'       => 'GroupingName',
		'name'     => 'GroupingName',
		'value'    => 'GroupMerge',
		'required' => 1,

	);
	$c->form->jsfunc('transferData(form)');
	if ( $c->form->submitted && $c->form->validate ) {
		## exclude some samples!!
		my $analysis_conf = $self->config_file( $c, 'rscript.Configs.txt' );
		my $dataset = $self->__process_returned_form($c);
		my $script =
		  $c->model('RScript')->create_script( $c, 'regroup', $dataset );
		$c->model('RScript')
		  ->runScript( $c, $path, 'ReorderGroups.R', $script, 1 );

		unless ( ref( $c->stash->{'ERROR'} ) eq "ARRAY" ) {
			$c->model('scrapbook')->init( $c->scrapbook() )
			  ->Add("<h3>User reordered a given grouping</h3>\n<i>options:"
				  . $self->options_to_HTML_table($dataset)
				  . "</i>\n" );
			$c->res->redirect(
				$c->uri_for("/analyse/re_run/$dataset->{GroupingName}") );
			$c->detach();
		}

	}
	if ( -f $path . 'facs_Heatmap.png' ) {
		$c->stash->{'HeatmapStatic'} = join(
			"",
			$self->create_selector_table_4_figures(
				$c,                             'heatmaps_s',
				'heatpic_s',                    'picture_s',
				'CorrelationPlot.png',          'PCR_Heatmap.png',
				'PCR_color_groups_Heatmap.png', 'facs_Heatmap.png',
				'facs_color_groups_Heatmap.png',
			)
		);
	}
	else {
		$c->stash->{'HeatmapStatic'} = join(
			"",
			$self->create_selector_table_4_figures(
				$c, 'heatmaps_s',
				'heatpic_s', 'picture_s', 'CorrelationPlot.png',
				'PCR_Heatmap.png', 'PCR_color_groups_Heatmap.png',

			)
		);
	}
	$self->JavaScript($c);
	$c->stash->{'template'} = 'Regroup.tt2';
}

sub rgbToHex {
	my ( $self, $red, $green, $blue ) = @_;
	my $string = sprintf( " #%2.2X%2.2X%2.2X\n", $red, $green, $blue );
	chomp($string);
	return ($string);
}

sub source_groups {
	my ( $self, $c ) = @_;
	my $path = $c->session_path();

	my $data_table = data_table->new();
	open( IN, "<$path" . 'Sample_Colors.xls' )
	  or Carp::confess("Internal libraray problem: File not found: $!\n");
	$data_table->{'used'} = {};
	open( LOG, ">>$path" . "Logfile_Regroup.txt" );
	while (<IN>) {
		chomp($_);
		unless ( defined @{ $data_table->{'header'} }[0] ) {
			$data_table->Add_2_Header( $data_table->__split_line($_) );
		}
		else {
			$data_table->{'tmp'} = $data_table->__split_line($_);
			unless ( $data_table->{'used'}->{ @{ $data_table->{'tmp'} }[2] } ) {
				push( @{ $data_table->{'data'} }, $data_table->{'tmp'} );
				$data_table->{'used'}->{ @{ $data_table->{'tmp'} }[2] } = 1;
			}
		}
	}
	close(IN);
	$data_table = $data_table->Sort_by(
		[ [ @{ $data_table->{'header'} }[2], 'numeric' ] ] );
	my $str2 = my $str = '';
	my $i = 1;
	my $percent_width = int( 95 / $data_table->Lines() );
	$c->stash->{'sourceGroups'} = '';
	$c->stash->{'groups'}       = $data_table->Lines();
	my ( $red, $green, $blue );

	foreach ( @{ $data_table->GetAll_AsHashArrayRef() } ) {
		( $red, $green, $blue ) =
		  split( " ", $_->{'colors'} );
		$str2 .=
		    "<button style=\"width:$percent_width\%;height:70;background-color:"
		  . $self->rgbToHex( $red, $green, $blue )
		  . "\"><b>Group $i</b></button>\n";
		$str .=
"<div id='div$i'  class='resizableContainer' ondrop='drop(event)' ondragover='allowDrop(event)'>\n</div>";
		$c->stash->{'sourceGroups'} .=
"<canvas id='Group$i' name='Group$i' style='width:$percent_width\%;height:70px;background-color:"
		  . $self->rgbToHex( $red, $green, $blue )
		  . "' draggable='true' ondragstart='drag(event)' >Group $i</canvas>";
		$i++;
	}
	$c->stash->{'sourceGroups'} = join(
		"</td></tr><tr>\n<td >\n",
		$str2,
		$c->stash->{'sourceGroups'},
		"<p>The new grouping slots:</p>" . $str
	);
	print LOG
"source_groups\nsource_groups groups =  $c->stash->{'groups'}\nsource_groups data_table:\n"
	  . $data_table->AsString()
	  . "source_groups resulting String\n"
	  . join(
		"</td></tr><tr>\n<td >\n",
		$str2,
		$c->stash->{'sourceGroups'},
		"<p>The new grouping slots:</p>" . $str
	  ) . "\n\n";

	close(LOG);
	return $str;
}

sub JavaScript {
	my ( $self, $c ) = @_;
	$self->Script(
		$c,
		'<script>' . "\n" . 'function transferData(form) {' . "\n" . join(
			"",
			map {
"copyNames( document.getElementById( 'div$_' ).children, form.g$_ )\n"
			  } 1 .. $c->stash->{'groups'}
		  )
		  . "\n}\n</script>\n"
		  . '<script type="text/javascript" src="'
		  . $c->uri_for('/scripts/analysis_index.js') . '"'
		  . "></script>\n"
		  . '<script type="text/javascript" src="'
		  . $c->uri_for('/scripts/figures.js') . '"'
		  . "></script>\n"
	);
	open( LOG, ">>" . $c->session_path() . "Logfile_Regroup.txt" );
	print LOG "JavaScript: script:n"
	  . $self->Script($c)
	  . "\nJavaScript groups: $c->{stash}->{' groups '}\n";
	close(LOG);
}

