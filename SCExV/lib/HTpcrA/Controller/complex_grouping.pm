package HTpcrA::Controller::complex_grouping;
use HTpcrA::EnableFiles;
use Moose;
use namespace::autoclean;

with 'HTpcrA::EnableFiles';

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

HTpcrA::Controller::complex_grouping - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

sub index : Path : Form {
	my ( $self, $c ) = @_;

	#my $hash = $self->config_file( $c, 'complexGrouping.Configs.txt' );
	my $path = $self->check($c);

	$c->form->type('TT2');
	$c->stash->{'template'} = 'complexHeatmap.tt2';
}


sub geneorder : Local : Form {
	my ( $self, $c, $group ) = @_;
	my $path = $self->check($c);

	$c->stash->{'text'} =
"Please copy the gene names from the left side to the right side in the correct order.\n"
	  . "The new order will become available at the analysis page and a press on the submitt will re-run the analysis using the gene order.\n";
	
	$self->Script(
		$c,  "<script>"
		. "function clearTextArea( name ) {\n"
		. "   var form = document.forms[0];\n"
		. "   form[name].value = '';\n"
		. "}\n</script>\n");
	my @genes = $c->genenames();

	$c->stash->{'genes'}   = join( "<BR>", sort @genes );
	$c->stash->{'columns'} = 20;
	$c->stash->{'rows'}    = scalar(@genes);

	$c->form->field(
		'id'       => "gOrder",
		'name'     => "Ordered Genes",
		'value'    => join( "\n", sort(@genes) ),
		'required' => 1,
		'type'     => 'textarea',
		'cols'     => 20,
		'rows'     => scalar(@genes),
	);
	$c->form->field(

		'id'       => 'GroupingName',
		'name'     => 'GroupingName',
		'value'    => 'UserGeneOrder',
		'required' => 1,

	);

	if ( $c->form->submitted && $c->form->validate ) {
		my $dataset = $self->__process_returned_form($c);
		#Carp::confess( root::get_hashEntries_as_string( $dataset , 3, "The return form") );
		$dataset->{'gOrder'} = [ split( /\s+/, $dataset->{'Ordered Genes'} ) ];
		unless ( $c->stash->{'genes'} eq
			join( "<BR>", sort ( @{ $dataset->{'gOrder'} } ) ) )
		{
			$c->stash->{'ERROR'} =
"Sorry, but I need that you give me each gene from the left list exactly one time.</BR>".$c->stash->{'genes'}." vs ".join( "<BR>", sort ( @{ $dataset->{'gOrder'} } ) ) ;
		}
		else {
			my $script =
			  $c->model('RScript')->create_script( $c, 'geneorder', $dataset );
			$c->model('RScript')
			  ->runScript( $c, $path, 'add_geneorder.R', $script, 'wait' );

			$c->model('scrapbook')->init( $c->scrapbook() )
			  ->Add("<h3>Add a user defined gene order</h3>\n<i>options:"
				  . $self->options_to_HTML_table($dataset)
				  . "</i>\n" );
			
			$c->res->redirect(
				$c->uri_for("/analyse/re_run/".$c->usedSampleGrouping()."/$dataset->{'GroupingName'}/") );
			$c->detach();
		}
	}

	$c->form->type('TT2');
	$c->stash->{'template'} = 'geneorder.tt2';
}

sub genegroup : Local : Form {
	my ( $self, $c, $group ) = @_;
	my $path = $self->check($c);
	
	$self->Script(
		$c,  '<script type="text/javascript" src="'
		  . $c->uri_for('/scripts/dynamicFormAdd.js') . '"'
		  . "></script>\n");
	
	$self->{'form_array'} = [];
	$c->form->field(
		'id'   => "GeneGroup_counter",
		'name' => "GeneGroup_counter" ,
		'value'    => 1,
		'required' => 1,
		'type'     => 'hidden',
	);
	$c->form->field(
		'id'   => "GeneGroup[]",
		'name' => "GeneGroup[]" ,
		'value'    => "",
		'required' => 1,
		'multiple' => 1,
		'type'     => 'textarea',
	);
	$c->form->field(

		'id'       => 'GroupingName',
		'name'     => 'GroupingName',
		'value'    => 'UserGeneOrder',
		'required' => 1,

	);
	
	if ( $c->form->submitted && $c->form->validate ) {
		my $analysis_conf = $self->config_file( $c, 'rscript.Configs.txt' );
		
		my $dataset = $self->__process_returned_form($c);
		
		my @genes = sort $c->genenames();
		my @userG = sort map{ chomp; split(/\s+/, $_) } @{$dataset->{'GeneGroup[]'}};
		
		unless ( join(" ",@genes) eq
			join( " ", @userG ) )
		{
			$c->stash->{'ERROR'} =
"Sorry, but I need that you give me each gene from the left list exactly one time.</BR>".join(" ",@genes)."</BR>".join(" ",@userG) ;
		}
		else {
			my $script =
			  $c->model('RScript')->create_script( $c, 'genegrouping', $dataset );
			$c->model('RScript')
			  ->runScript( $c, $path, 'add_genegroup.R', $script, 'wait' );

			$c->model('scrapbook')->init( $c->scrapbook() )
			  ->Add("<h3>Add a user defined gene grouping</h3>\n<i>options:"
				  . $self->options_to_HTML_table($dataset)
				  . "</i>\n" );
				  
			$c->res->redirect(
				$c->uri_for("/analyse/re_run/".$c->usedSampleGrouping()."/$dataset->{'GroupingName'}/") );
			$c->detach();
		}
	}
	$c->form->type('TT2');
	$c->form->template( $c->config->{'root'} . 'src' . '/form/genegroups.tt2' );
	$c->stash->{'template'} = 'genegroups.tt2';
}

sub colorpicker : Local : Form {
	my ( $self, $c, $group ) = @_;
	my $path = $self->check($c);

	## somehow work on this:
	## <input type="color" id="html5colorpicker" onchange="clickColor(0, -1, -1, 5)" value="#ff0000" style="width:85%;">
	$self->{'form_array'} = [];
	$self->source_groups($c);
	foreach ( my $i = 0 ; $i < @{ $c->stash->{'groups'} } ; $i++ ) {
		$c->form->field(
			'id'   => "g" . ( $i + 1 ),
			'name' => "g" . ( $i + 1 ),
			'value'    => @{ $c->stash->{'groups'} }[$i],
			'required' => 1,
			'type'     => 'hidden',

		);
	}
	if ( $c->form->submitted && $c->form->validate ) {
		my $analysis_conf = $self->config_file( $c, 'rscript.Configs.txt' );
		
		my $dataset = $self->__process_returned_form($c);
		while ( my ( $k, $v ) = each(%$dataset) ) {
			$analysis_conf->{$k} = $v;
		}
		$analysis_conf->{groups} = scalar( @{ $c->stash->{'groups'} } );
		my $script =
		  $c->model('RScript')->create_script( $c, 'recolor', $analysis_conf );
		$c->model('RScript')
		  ->runScript( $c, $path, 'recolor.R', $script, 'wait' );

		unless ( ref( $c->stash->{'ERROR'} ) eq "ARRAY" ) {
			$c->model('scrapbook')->init( $c->scrapbook() )
			  ->Add(
				"<h3>Change the colors in a grouping dataset</h3>\n<i>options:"
				  . $self->options_to_HTML_table($analysis_conf)
				  . "</i>\n" );
			$c->res->redirect( $c->uri_for("/analyse/re_run/".$c->usedSampleGrouping()."/") );
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
	$c->form->type('TT2');
	$c->stash->{'template'} = 'colorpicker.tt2';
}

sub JavaScript {
	my ( $self, $c ) = @_;
	$self->Script(
		$c,
"<script>\nfunction up(d,mul)\n{\n    form = document.forms[0];\n    form[d].value=mul;\n}\</script>"

		  . '<script type="text/javascript" src="'
		  . $c->uri_for('/scripts/analysis_index.js') . '"'
		  . "></script>\n"
		  . '<script type="text/javascript" src="'
		  . $c->uri_for('/scripts/figures.js') . '"'
		  . "></script>\n"
	);
}

sub source_groups {
	my ( $self, $c ) = @_;
	my $path = $c->session_path();

	my $data_table = data_table->new();
	open( IN, "<$path" . 'Sample_Colors.xls' )
	  or Carp::confess("Internal libraray problem: File not found: $!\n");
	$data_table->{'used'} = {};
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
	my $str           = '<table width="40%">';
	my $i             = 1;
	my $percent_width = int( 95 / $data_table->Lines() );
	$c->stash->{'sourceGroups'} = '';
	$c->stash->{'groups'}       = [];
	my ( $red, $green, $blue, $HexC );

	foreach ( @{ $data_table->GetAll_AsHashArrayRef() } ) {
		$HexC = $self->rgbToHex( split( " ", $_->{'colors'} ) );
		push( @{ $c->stash->{'groups'} }, $HexC );
		$str .=
		    "<tr><td>"
		  . "<b>Group $i:</b>  <input value=\""
		  . $HexC
		  . "\" type=\"color\" onchange=\""
		  . "up('g$i', document.getElementById('group_$i').value);"
		  . "\" id=\"group_$i\"></td></tr>\n";
		$i++;
	}
	$c->stash->{'sourceGroups'} = join( "\n",
		"<div id=\"html5DIV\">",
		"<p>Click the group colors to change them using HTML5:</p>",
		$str, "</div>" );

	return $str;
}

sub rgbToHex {
	my ( $self, $red, $green, $blue ) = @_;
	my $string = sprintf( "#%2.2X%2.2X%2.2X\n", $red, $green, $blue );
	chomp($string);
	return ($string);
}

=encoding utf8

=head1 AUTHOR

Stefan Lang,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
