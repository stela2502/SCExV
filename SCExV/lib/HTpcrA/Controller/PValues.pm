package HTpcrA::Controller::PValues;
use Moose;
use namespace::autoclean;
with 'HTpcrA::EnableFiles';
BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

HTpcrA::Controller::PValues - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

sub index : Path : Form {
	my ( $self, $c ) = @_;
	$c->model('Menu')->Reinit();
	my $path = $c->session->{'path'};
	unless ( $self->file_upload($c) ) {    ## there are no uploaded files!
		$c->res->redirect( $c->uri_for("/files/upload/") );
		$c->detach();
	}
	unless ( -d $path . 'webGL' ) {
		$c->res->redirect( $c->uri_for("/analyse/") );
		$c->detach();
	}
	$self->{'form_array'} = [];
	my $hash = $self->config_file( $c, 'Pvalues.Configs.txt' );
	$hash = $self->defined_or_set_to_default( $hash, $self->init_dataset() );
	push(
		@{ $self->{'form_array'} },
		{
			'comment'  => 'random iteration rounds',
			'name'     => 'boot',
			'value'    => $hash->{'boot'},
			'required' => 1,
		}
	);
	push(
		@{ $self->{'form_array'} },
		{
			'comment'  => 'Linear stat output file name',
			'name'     => 'lin_lang_file',
			'value'    => $hash->{'lin_lang_file'},
			'required' => 1,
			'type' => 'hidden',
		}
	);
	push(
		@{ $self->{'form_array'} },
		{
			'comment'  => 'SingleCellAssay p values output file',
			'name'     => 'sca_ofile',
			'value'    => $hash->{'sca_ofile'},
			'required' => 1,
			'type' => 'hidden',
		}
	);
	## now start the P_value calculation
	foreach ( @{ $self->{'form_array'} } ) {
		$c->form->field( %{$_} );
	}
	if ( $c->form->submitted && $c->form->validate ) {
		$hash = $self->__process_returned_form($c);
		$c->model('PValues')->create_script( $c, $hash );
		
		$c->model('scrapbook')->init( $path."/Scrapbook/Scrapbook.html" )
	  ->Add_Table("<h3>P values calculation</h3>\n<p>You can <a href='TABLE_FILE'>download the stat results</a>.</p>\n", $self->path($c)."Summary_Stat_Outfile.xls" );
	}
	if ( -f $path . "Summary_Stat_Outfile.xls" ) {
		my $data_table = stefans_libs::GeneGroups::R_table->new(
			{ 'filename' => $path . "Summary_Stat_Outfile.xls" } );
		$data_table->HTML_id('sortable');
		foreach (
			@{ $data_table->{'header'} }[ 1 .. ( $data_table->Columns() - 1 ) ]
		  )
		{
			$data_table->HTML_modification_for_column(
				{ 'column_name' => $_, 'th' => 'class="numeric"' } );
		}
		$data_table->{'path_to_images'} = $c->uri_for("/files/index$path");
		$data_table->HTML_line_mod(
			sub {
				my ( $self, $array ) = @_;
				return
"onClick='updateimage(\"mygallery\", \"pictures\", \"$self->{'path_to_images'}@$array[0].png\" )'";
			}
		);

		$data_table->Rename_Column( 'Samples', 'Gene' );
		$c->stash->{'stat_res'} = $data_table->GetAsHTML();
		$c->stash->{'figure_2d'} =
		    "<p align='center'><img src='".$c->uri_for('/static/images/Empty_selection.png')."', width='100%' id='pictures'>";
		
		
	}
	$self->Script( $c,
	    '<script type="text/javascript" src="'
	  . $c->uri_for("/scripts/jquery.min.js")
	  . '"></script>' . "\n"
	  . '<script type="text/javascript" src="'
	  . $c->uri_for("/scripts/table_paginate.js")
	  . '"></script>' . "\n"
	  . '<link type="text/css" href="'
	  . $c->uri_for("/css/table_sorter.css")
	  . '" rel="stylesheet" />' . "\n");
	$c->form->template( $c->path_to( 'root', 'src' ) . '/form/Pvalues_form.tt2' );
	$c->stash->{'template'} = 'pvalues.tt2';
}

sub init_dataset {
	return my $dataset = {
		'boot'          => 1000,
		'lin_lang_file' => 'lin_lang_stats.xls',
		'sca_ofile'     => "Significant_genes.csv"
	};
}

=head1 AUTHOR
  
  Stefan Lang

=head1 LICENSE

  This library is free software . You can redistribute it and /or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
