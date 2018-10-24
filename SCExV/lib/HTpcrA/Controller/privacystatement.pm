package HTpcrA::Controller::privacystatement;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

HTpcrA::Controller::privacystatement - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched HTpcrA::Controller::privacystatement in privacystatement.');
}



sub index : Path  {
	my ( $self, $c ) = @_;
	my $path = $c->config->{'root'} . "/tmp/";
	$c->model('Menu')->Reinit();

	unless ( defined $c->session->{'known'} ) {
		$c->session->{'known'} = 0;
	}
	elsif ( $c->session->{'known'} == 0 ) {
		$c->session->{'known'} = 1;
	}

   #Carp::confess( "find ".$path." -maxdepth 1 -mtime +1 -exec rm -Rf {} \\;" );
   #system( "find " . $path . " -maxdepth 1 -mtime +1 -exec rm -Rf {} \\;" );
	$c->{'stash'} -> {'message'} = "No personal data is stored on this server. "
	. "<p>All data uploaded to the server is deleted after one hour without usage.</p>"
	. "IP addresses are anonymized using <a href='https://matomo.org/', target='_blank'>Matamo</a>.";
	
	## this position can be used to upload the files!
	$c->stash->{'template'}   = 'privacystatement.tt2';
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
