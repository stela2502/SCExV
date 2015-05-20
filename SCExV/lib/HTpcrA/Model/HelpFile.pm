package HTpcrA::Model::HelpFile;

use strict;
use warnings;
use parent 'Catalyst::Model';

use stefans_libs::file_readers::help_data;

sub new {
	my ( $app, @arguments ) = @_;
	return  stefans_libs::file_readers::help_data->new();
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