package HTpcrA;
use Moose;
use namespace::autoclean;
use File::Spec;

use Catalyst::Runtime 5.80;

# Set flags and add plugins for the application.
#
# Note that ORDERING IS IMPORTANT here as plugins are initialized in order,
# therefore you almost certainly want to keep ConfigLoader at the head of the
# list if you're using it.
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

#	+CatalystX::Profile_SL
#	-Debug

use Catalyst qw/
  ConfigLoader
  Static::Simple
  Session
  Session::State::Cookie
  Session::Store::FastMmap
  FormBuilder
  /;

extends 'Catalyst';

our $VERSION = '0.60';

# Configure the application.
#
# Note that settings in PCR_analysis.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(
	name => 'HTpcrA',
	# Disable deprecated behavior needed by old applications
	#disable_component_resolution_regex_fallback => 1,
	calcserver => {'ip' => '130.235.249.196', 'subpage' => '/NGS_pipeline/fluidigm/index/', 'ncore' => 32 },
	randomForest => 0,
	ncore => 4,
	enable_catalyst_header => 1,                        # Send X-Catalyst header
	'View::HTML'           => { 'CATALYST_VAR' => 'c' },
	default_view           => 'HTML',
	session                => { 'flash_to_stash' => 1 },

);


# Start the application
__PACKAGE__->setup();
## clean up script to be used with cron script/CleanTemp.pl

##Carp::confess ( "The optional path values to find the config file:\n".join("\n",__PACKAGE__->find_files(), "root path:",  __PACKAGE__->config->{'root'} ). "\n" );

sub cookie_check{
	my ( $self ) = @_;
	return 1 if ( $self->session->{'known'} == 1);
	unless ( defined $self->session->{'known'} ){
		$self->session->{'known'} = 0;
	}elsif ( $self->session->{'known'} == 0 ){
		$self->session->{'known'} = 1;
	}
	return 1;
}

sub check_IP{
	my ( $self ) = @_;
	foreach ( map{ if ( ref($_) eq "ARRAY"){@$_} else { $_ } } $self->config->{'calcserver'}->{'ip'} ){
		return 1 if ( $self->req->address() eq $_ );
	}
	$self->res->redirect('/access_denied');
	$self->detach();
}

sub session_path {
	my ($self, $session_id ) = @_;
	if ( defined $session_id ){
		return $self->config->{'root'}. "/tmp/" . $session_id ."/";
	}
	my $path = $self->session->{'path'};
	
	if (defined $path){
		return $path if ( $path =~ m!/tmp/[\w\d]! && -d $path );
	}
	my $root = $self->config->{'root'};

	#	my $root = "/var/www/html/HTPCR";
	$session_id = $self->get_session_id();
	unless ( $session_id = "[w\\d]" ) {
		$self->res->redirect( $self->uri_for("/") );
		$self->detach();
	}
	$path = $root . "/tmp/" . $self->get_session_id() . "/";
	$path = $root . "/tmp/" . $self->get_session_id() . "/" if ($path =~ m!//$! );
	unless ( -d $path ) {
		mkdir($path)
		  or Carp::confess("I could not create the session path $path\n$!\n");
		mkdir( $path . "libs/" );
		system( "cp $root/R_lib/Tool* $path" . "libs/" );
		Carp::confess(
			"cp $root/R_lib/Tool* $path" . "libs/\n did not work: $!\n" )
		  unless ( -f $path . "libs/Tool_Pipe.R" );
	}
	$self->session->{'path'} = $path;
	return $path;
}

sub scrapbook {
	my ( $self ) = @_;
	return $self->session->{'path'}."/Scrapbook/Scrapbook.html" ;
}
=head1 NAME

HTpcrA - Catalyst based application

=head1 SYNOPSIS

    script/PCR_analysis_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<HTpcrA::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Stefan Lang

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
