package HTpcrA::Model::RandomForest;
use Moose;
use namespace::autoclean;
use POSIX;
use LWP::Simple;

extends 'Catalyst::Model';

use Digest::MD5;

=head1 NAME

HTpcrA::Model::RandomForest - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 AUTHOR

Stefan Lang

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.


=head2 RandomForest

This tool will make sure, that the random forest is created.
It will also create a RandomForest script calculating the thing.
If the RandomForest is created calling this function will create 
a user group named RandomForest_n5 (e.g. 5 groups)
These groups will be created whenever the calculation is finished.

This tool will also evaluate some config variables to see whether 
there is a calculation server attached to this server.

$config->{'calcserver' => {
	'to' => 'http://123.123.123.123/cgi-bin/foresthelper/reciever.cgi',
	'ncore' => 32,
}}

=cut

#sub new {
#	my ( $app, @arguments ) = @_;
#	return HTpcrA::Model::RandomForest->new();
#}

sub RandomForest {
	my ( $self, $c, $dataset ) = @_;
	my $path = $c->session_path();
	if (
		defined $c->config->{'calcserver'}->{'ip'}
		and get(
			    'http://'
			  . $c->config->{'calcserver'}->{'ip'}
			  . $c->config->{'subpage'}
		)
	  )
	{
		Carp::confess(
"To send the random forest calculation to a web server is not implemented!"
		);
	}
	return $self->localRFcluster( $c, $dataset );
}

sub localRFcluster {
	my ( $self, $c, $dataset ) = @_;
	
	if ( $c->config->{production} ){
		Carp::confess ("The random forest is unavailable in a production setting. "
		."Please use href='http://bone.bmc.lu.se/Public/med-sal/SCExV/SCexV_Ubuntu.ova'"
		." target='blank'>the virtual machine</a> on a local system.");
		
	}
	else {
	my $path = $c->session_path();
	$c->stash->{'ERROR'} =
"Only local random forest clustering available - this will block the server for about 15 min."
	  . " So please do not use this on a production system - download the virtual machine from ftp://bone.bmc.lu.se/Public/med-sal/SCExV/ and run it from there.";
	if ( $c->config->{'production'} ) {
		Carp::confess( $c->stash->{'ERROR'} );
	}
		  
	my $script =
	  $c->model('RScript')->create_script( $c, 'run_RF_local', $dataset );
	$c->model('RScript')
	  ->runScript( $c, $path, 'run_RF_local.R', $script, 0 );

	$c->res->redirect(
		$c->uri_for(
			    "/analyse/" ## this calculation will take a lot of time - so do not block the server while waiting!
		)
	);
	
	$c->detach();
	}
}


sub file2md5str {
	my ( $self, $filename ) = @_;
	my $md5_sum = 0;
	if ( -f $filename ) {
		open( FILE, "<$filename" );
		binmode FILE;
		my $ctx = Digest::MD5->new;
		$ctx->addfile(*FILE);
		$md5_sum = $ctx->b64digest;
		close(FILE);
	}
	return $md5_sum;
}


__PACKAGE__->meta->make_immutable;

1;
