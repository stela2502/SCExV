package HTpcrA::Controller::complex_grouping;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

HTpcrA::Controller::complex_grouping - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Form {
    my ( $self, $c ) = @_;
	#my $hash = $self->config_file( $c, 'complexGrouping.Configs.txt' );
	$c->model('Menu')->Reinit();
	
	$c->form->type('TT2');
	#$c->form->template( $c->config->{'root'} . 'src' . '/form/complexHeatmap.tt2' );
	$c->stash->{'template'} = 'complexHeatmap.tt2';
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
