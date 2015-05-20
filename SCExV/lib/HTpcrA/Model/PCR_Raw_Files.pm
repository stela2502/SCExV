package HTpcrA::Model::PCR_Raw_Files;

use Moose;

BEGIN {extends 'Catalyst::Model' };

use namespace::autoclean;
use POSIX;

use stefans_libs::file_readers::PCR_Raw_Tables;


sub new {
	my ( $app, @arguments ) = @_;
	return stefans_libs::file_readers::PCR_Raw_Tables->new();
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