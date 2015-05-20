package HTpcrA::Model::MethodsSection;

use strict;
use warnings;
use parent 'Catalyst::Model';

use stefans_libs::HTpcrA::methods;



sub new {
	my ( $app, @arguments ) = @_;
	return stefans_libs::HTpcrA::methods->new();
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