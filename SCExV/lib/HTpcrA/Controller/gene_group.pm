package HTpcrA::Controller::gene_group;
use Moose;
use namespace::autoclean;
use HTpcrA::EnableFiles;

with 'HTpcrA::EnableFiles';

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

HTpcrA::Controller::gene_group - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

sub update_form {
	my ( $self, $c, $dataset ) = @_;
	opendir( DIR, $self->path($c) )
	  or die "I could not read from path '" . $self->path($c) . "'\n$!\n";
	my @tmp =
	  $self->create_selector_table_4_figures( $c, 'mygallery', 'pictures',
		'GOI', sort grep /\.png/,
		readdir(DIR) );
	closedir(DIR);

	splice( @tmp, 1, 1 );    ## kick out the select box!
	$c->stash->{'Genes'} = join( "", @tmp );

	$c->form->name('mygallery');
	push(
		@{ $self->{'form_array'} },
		{
			'comment' => 'Select your gene of interest',
			'name'    => 'GOI',
			'options' => $self->{'select_options'}
			,                ## you will break the R_script changing this text!
			'jsclick'  => "showimage('mygallery', 'pictures','GOI')",
			'required' => 1,
		}
	);

	push(
		@{ $self->{'form_array'} },
		{
			'comment'  => 'Breakpoint values',
			'name'     => 'cutoff',
			'required' => 1,
		}
	);
	foreach ( @{ $self->{'form_array'} } ) {
		$c->form->field( %{$_} );
	}
	$c->form->submit( [ 'Update', 'Analyse using this grouping' ] );
}

sub index : Path : Args(0) : Form {
	my ( $self, $c ) = @_;
	$self->check($c,'upload');
	$c->model('Menu')->Reinit();
	unless ( $c->form->submitted ) {
		unlink( $self->path($c) . "R.error" )
		  if ( -f $self->path($c) . "R.error" );
		opendir( DIR, $self->path($c) );
		$self->R_script($c)
		  if ( scalar( grep ( /png$/, readdir(DIR) ) ) == 0 );
		closedir(DIR);

	}
	$self->update_form($c);
	if ( $c->form->submitted && $c->form->validate ) {
		if ( $c->form->submitted() eq "Update" ) {
			my $dataset = $self->__process_returned_form($c);
			$self->Update_Groups( $c, $dataset );
			$self->R_script($c);
			$self->update_form($c);
		}
		elsif ( $c->form->submitted() eq "Analyse using this grouping" ) {
			my $dataset = $self->__process_returned_form($c);
			my $figure_file = $self->Update_Groups( $c, $dataset );
			$c->model('scrapbook')->init( $c->scrapbook() )->Add(
				"<h3>Create Grouing based on one gene</h3>\n<i>options:"
				  . $self->options_to_HTML_table($dataset)
				  . "</i>\n"
			);
			$c->model('scrapbook')->init( $c->scrapbook() )->Add( "The final gouping for gene $dataset->{'GOI'}",
				$self->path($c) . $figure_file
			);
			$c->res->redirect(
				$c->uri_for("/analyse/re_run/$dataset->{GOI}&nbsp;1D&nbsp;Group") );
			$c->detach();
		}

	}

	if ( -f $c->session_path() . "R.error" ) {
		open( IN, "<" . $c->session_path() . "R.error" );
		$c->stash->{'message'} .= join( "", <IN> );
		close(IN);
	}
	$self->Script( $c,
		    '<script type="text/javascript" src="'
		  . $c->uri_for('/scripts/figures.js')
		  . '"></script>' );
	$c->form->type('TT2');

	$c->form->template( $c->config->{'root'}.'src'. '/form/gene_group.tt2' );
	$c->stash->{'template'} = 'gene_group.tt2';
}

sub recreate_figures : Local {
	my ( $self, $c ) = @_;
	system( 'rm ' . $self->path($c) . "/*.png" );
	$c->res->redirect( $c->uri_for("/gene_group/") );
	$c->detach();
}

sub Update_Groups {
	my ( $self, $c, $dataset ) = @_;
	my @temp = split( "/", $dataset->{'GOI'} );
	my $figure_file = $dataset->{'GOI'} = pop(@temp);
	$dataset->{'GOI'} =~ s/.png//;

	$dataset->{'cutoff'} =~ s/,/./g;
	$dataset->{'path'} = $self->path($c);

	my $script = $c->model('RScript')->create_script($c, 'geneGroup1D', $dataset );
	$c->model('RScript')->runScript( $c, $c->session_path() , "Grouping.$dataset->{GOI}" , $script );

	return $figure_file;
}

sub path {
	my ( $self, $c ) = @_;
	Carp::confess("I need a HTpcrA object at startup!\n")
	  unless ( defined $c );
	my $path = $c->session_path() . 'GG_prep/';
	mkdir($path) unless ( -d $path );
	return $path;
}

sub R_script {    ## to plot the histograms!!
	my ( $self, $c ) = @_;    #the dataset created from the input form
	my $path = $self->path($c);
	mkdir($path) unless ( -d $path );
	my $dataset;
	$dataset->{'path'} = $path;
	$dataset->{'subpath'} = 'GG_prep';
	
	##init script
	my $script = $c->model('RScript')->create_script($c, 'geneGroup1D_backend', $dataset );
	$c->model('RScript')->runScript( $c, $path."../", 'Gene_Group_Prepare.R', $script, 1 );
	
	return 1;
}

=head1 AUTHOR

Stefan Lang

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
