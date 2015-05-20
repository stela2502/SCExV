package HTpcrA::View::HTML;

use strict;
use base 'Catalyst::View::TT';

__PACKAGE__->config({
    INCLUDE_PATH => [
        HTpcrA->config()->{'root'}. '/src' ,
        HTpcrA->config()->{'root'}. '/lib' ,
        HTpcrA->config()->{'root'}. '/../src' ,
        HTpcrA->config()->{'root'}. '/../lib' ,
    ],
    PRE_PROCESS  => 'config/main',
    WRAPPER      => 'site/wrapper',
    ERROR        => 'error.tt2',
    TIMER        => 0,
    render_die   => 1,
});


=head1 NAME

HTpcrA::View::HTML - Catalyst TTSite View

=head1 SYNOPSIS

See L<HTpcrA>

=head1 DESCRIPTION

Catalyst TTSite View.

=head1 AUTHOR

Stefan Lang

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

