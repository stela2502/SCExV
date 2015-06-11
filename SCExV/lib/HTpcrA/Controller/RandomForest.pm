package HTpcrA::Controller::RandomForest;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }
with 'HTpcrA::EnableFiles';
use Digest::MD5;
=head1 NAME

HTpcrA::Controller::RandomForest - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index : Local : Form  {
    my ( $self, $c, @args ) = @_;
	$self->{'form_array'} = [];
	$c->form->method('post');
	$c->form->field(
			'comment'  => 'session',
			'name'     => 'session',
			'type' => 'text',
			'required' => 1,
	);
	$c->form->field(
			'comment'  => 'file',
			'name'     => 'fn',
			'type' => 'file',
			'required' => 1,
	);
	$c->form->field(
			'comment'  => 'md5',
			'name'     => 'md5',
			'type' => 'text',
			'required' => 1,
	);
	if ( $c->form->submitted && $c->form->validate ) {
		#warn root::get_hashEntries_as_string($c->req->uploads() , 3, "Uploads") ;
		my $upload  = $c->req->uploads()->{'fn'};# $c->form->field('fn') ;
		my $ctx = Digest::MD5->new;
		$ctx->addfile($upload->fh());
		my $md5_sum = $ctx->b64digest;
		unless ( $md5_sum eq $c->form->field('md5') ) {
			## this file is not the right file!
			$c->response->body('Sorry, but this file has not the right md5 sum!('. $md5_sum.")\n" );
			$c->model('scrapbook')->init( $c->scrapbook() )->Add('Sorry, but this file has not the right md5 sum!('. $md5_sum.")\n");
			$c->detach();
		}
		my $res  = $c->model('RandomForest') -> recieve_RandomForest( $c, $upload, $c->form->field('session') );
		unless ( $res ){
			## Oh too late - this session has expired!
			$c->response->body('Sorry, but this session has expired!'. $c->form->field('session') ."\n" );
			$c->detach();
		}
		$c->response->body("Done!\n" );
		$c->detach();
	}
	$c->stash->{'template'} = 'message.tt2';
}

sub recalculate : Local : Form {
	my ( $self, $c, @args ) = @_;
	$self->check($c,'upload');
	$self->{'form_array'} = [];
	$c->form->field(
			'comment'  => 'total tree count (more is better and slower)',
			'name'     => 'total_trees',
			'type' => 'text',
			'value' => 6e+6,
			'required' => 1,
	);
	$c->form->field(
			'comment'  => 'number of Gene Groups',
			'name'     => 'gene_groups',
			'type' => 'text',
			'value' => 10,
			'required' => 1,
	);
	$c->form->field(
			'comment'  => 'Cluster ON',
			'name'     => 'cluster_on',
			'options' => ['Expression', 'FACS', 'both'],
			'value' => 'Expression',
			'required' => 1,
	);
	foreach ( @{ $self->{'form_array'} } ) {
		$c->form->field( %{$_} );
	}
	if ( $c->form->submitted && $c->form->validate ) {
		my $dataset = $self->__process_returned_form( $c );
		$c->model('scrapbook')->init( $c->scrapbook() )
	  ->Add("<h3>RandomForest calculation</h3>\n<p>I send the data to the calculation server!</p><i>"
		  . $self->options_to_HTML_table($dataset)
		  . "</i>\n" );
		$c->model('RandomForest') -> RandomForest ($c,  $dataset , 1);
		$c->res->redirect( $c->uri_for("/analyse/index/") );
		$c->detach();
	}
	$c->stash->{'template'} = 'message.tt2';
}

=head1 AUTHOR

Stefan Lang

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
