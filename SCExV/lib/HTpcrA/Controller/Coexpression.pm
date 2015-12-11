package HTpcrA::Controller::Coexpression;
use Moose;
use namespace::autoclean;
use HTpcrA::EnableFiles;

with 'HTpcrA::EnableFiles';

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

HTpcrA::Controller::Coexpression - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Form {
    my ( $self, $c ) = @_;
	my $path = $self->check($c,'analysis');
	my $hash = $self->config_file( $c, 'Correlation.Configs.txt' );
	$self->{'form_array'} = [];
	opendir( DIR, $path."/preprocess/" );
	my @not = ('_Heatmap.png', 'loadings', 'hc_checkup' );
	my (@files, $i);
	map { $i = 1; foreach my $key (@not) { $i = 0 if ( $_ =~ m/$key/)}; push ( @files,$_) if ( $i ); } readdir(DIR) ;
	closedir(DIR);
	my @tmp =
	  $self->create_selector_table_4_figures( $c, 'mygallery', 'pictures1',
		'controlG1', @files );
	push(
		@{ $self->{'form_array'} },
		{
			'comment'  => 'The seeder gene',
			'name'     => 'GOI',
			'value'    => $hash->{'GOI'},
			'values' => [],
			'required' => 1,
		}
	);
	
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
	#$c->form->template( $c->config->{'root'}.'src'. '/form/Coexpression_form.tt2' );
	$c->stash->{'template'} = 'coexpression.tt2';
  #  $c->response->body('This is a future feature - not implemented in this version of SCExV!');
}


=head1 AUTHOR

Stefan Lang

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
