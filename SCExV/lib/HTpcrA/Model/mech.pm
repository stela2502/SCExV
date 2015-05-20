package HTpcrA::Model::mech;

use Moose;
use namespace::autoclean;
use POSIX;

extends 'Catalyst::Model';

use WWW::Mechanize;

sub new {
	my ( $app, @arguments ) = @_;
	my $self = {};
	bless $self, 'HTpcrA::Model::mech';
	return $self;
}

sub post_randomForest {
	my ( $self, $c, $file, $md5_sum, $returnpage ) = @_;

	my $mech = WWW::Mechanize->new();
	$mech->get( 'http://'
		  . $c->config->{'calcserver'}->{'ip'}
		  . $c->config->{'calcserver'}->{'subpage'} );
	
	$mech->form_number(1);
	$mech->field(  'filename'   => $file  );
	$mech->field(  'key'        => $md5_sum  );
	$mech->field(  'session'    => $c->get_session_id()  );
	$mech->field(  'rpage' => $returnpage  );
	$mech->submit();
	return 1 if ( $mech->content() =~ m/Done!/ );
	Carp::confess( "putative error on the caluclation server - I did not recieve the 'Done!' signal\n", $c, $file, $md5_sum, $returnpage, $mech->content() );
}

=head1 NAME

Genexpress_catalist::Model::jobTable - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 AUTHOR

Stefan Lang

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
