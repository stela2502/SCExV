package HTpcrA::Controller::Root;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config( namespace => '' );

=head1 NAME

HTpcrA::Controller::Root - Root Controller for HTpcrA

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 index

The root page (/)

=cut

sub index : Path : Form : Args(0) {
	my ( $self, $c ) = @_;
	my $path = $c->config->{'root'} . "/tmp/";
	$c->model('Menu')->Reinit();
	
	unless ( defined $c->session->{'known'} ){
		$c->session->{'known'} = 0;
	}elsif ( $c->session->{'known'} == 0 ){
		$c->session->{'known'} = 1;
	}
	
   #Carp::confess( "find ".$path." -maxdepth 1 -mtime +1 -exec rm -Rf {} \\;" );
	#system( "find " . $path . " -maxdepth 1 -mtime +1 -exec rm -Rf {} \\;" );
	$c->stash->{'news'} = [ '2015.01.10:', 'A 2 components MDS figure for the gene clustering (loadings) is now available on the analysis page.' ];

	## this position can be used to upload the files!
	$c->stash->{'uploadPage'} = $c->uri_for("/files/upload/");
	$c->stash->{'template'}   = 'start.tt2';
}


sub end : ActionClass('RenderView') {
	my ( $self, $c ) = @_;
	if ( -f $c->session_path()."Sample_Colors.xls"){
		$c->model('Menu')
		  ->Add( 'Go To', '/dropsamples/index', "Exclude Cells" );
		$c->model('Menu')
		  ->Add( 'Go To', '/dropgenes/index', "Exclude Genes" );
	}
	$c->stash->{'sidebar'} = { 'container' => [ $c->model('Menu')->menu($c) ] };
	if (defined $c->stash->{'ERROR'}) {
		$c->stash->{'ERROR'} = [$c->stash->{'ERROR'}] unless ( ref($c->stash->{'ERROR'}) eq "ARRAY");
	}
}

sub kill : Local: Form {
	my ( $self, $c, @args ) = @_;
	Carp::confess ( join ( " ", @args ));
}

sub clear_all : Local : Form {
	my ( $self, $c ) = @_;
	$self->{'form_array'} = [];
	$c->form->method('post');
	$c->cookie_check();
	push(
		@{ $self->{'form_array'} },
		{
			'comment' =>
'<p>You are going to delete all your files from the server!</p><ul><li>Your data files</li><li>All groups you created</li><li>All results</li></ul>',
			'name'     => 'delte all',
			'type'     => 'checkbox',
			'required' => 0,
		}
	);
	foreach ( @{ $self->{'form_array'} } ) {
		$c->form->field( %{$_} );
	}
	$c->form->submit( 'DELETE', 'chancel' );
	if ( $c->form->submitted && $c->form->validate ) {
		if ( $c->form->submitted() eq "DELETE" ) {
			system( 'rm -R ' . $c->session_path() );
			$c->session->{'PCRTable'}  = undef;
			$c->session->{'PCRTable2'} = undef;
			$c->session->{'facsTable'}      = undef;
			$c->res->redirect( $c->uri_for("/files/upload/") );
			$c->detach();
		}
		else {
			$c->res->redirect( $c->uri_for("/analyse/") );
			$c->detach();
		}
	}

	$c->stash->{'template'} = 'welcome.tt2';
}

=head2 default

Standard 404 error page

=cut

sub default : Path {
	my ( $self, $c ) = @_;
	$c->response->body('Page not found');
	$c->response->status(404);
}

=head1 AUTHOR

Stefan Lang

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
