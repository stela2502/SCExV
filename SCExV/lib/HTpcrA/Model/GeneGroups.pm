package HTpcrA::Model::GeneGroups;

use strict;
use warnings;
use parent 'Catalyst::Model::Factory::PerRequest';

use stefans_libs::GeneGroups;

__PACKAGE__->config( class => 'stefans_libs::GeneGroups' );


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