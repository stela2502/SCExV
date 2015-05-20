# ABSTRACT: Control profiling within your application
package CatalystX::Profile_SL::Controller::ControlProfiling;
BEGIN {
  $CatalystX::Profile_SL::Controller::ControlProfiling::VERSION = '0.02';
}
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

use Devel::NYTProf;

sub stop_profiling : Local {
    my ($self, $c) = @_;
    DB::finish_profile();
    my $file = $c->config->{'root'}."/tmp/profiling/nytprof";
    #Carp::confess ( "nytprofhtml --file $file.out.*\n"."zip -r9 /profiling/nytprof_".time.".zip $file\n". "rm $file.out.*\n" );
    system ( "nytprofhtml --file $file.out.* --out $file" );
    system ( "zip -R9 $file"."_".time.".zip $file/*" );
    system ( "rm $file.out.*" );
    DB::enable_profile($file.".out");
    $c->log->debug('Profiling has now been restarted');
    $c->response->body('Profiling restrted <a href="file://'.$file.'/index.html" target="_blank">The profiling summary page</a>'. "</br>\nYou need to download all your data to get to all information. <a href='/'>Back to Start</a>" );
}



1;


__END__
=pod

=head1 NAME

CatalystX::Profile::Controller::ControlProfiling - Control profiling within your application

=head1 VERSION

version 0.02

=head1 DESCRIPTIONS

Some actions you can use to control profiling

=head1 ACTIONS

=head2 stop_profiling

Stop and finish profiling, and write all the output. This can be a bit
slow while the profiling data is written, but that's normal.

=head1 AUTHOR

Oliver Charles <oliver.g.charles@googlemail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Oliver Charles.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

