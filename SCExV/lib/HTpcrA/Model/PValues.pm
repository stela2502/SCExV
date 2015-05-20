package HTpcrA::Model::PValues;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Model';

=head1 NAME

HTpcrA::Model::PValues - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 AUTHOR

Stefan Lang

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

sub create_script {
	my ( $self, $c, $dataset ) = @_;
	my $path = $c->session->{'path'};
	unless ( -f $path . "/norm_data.RData" ) {
		$c->res->redirect( $c->uri_for("/files/upload/") );
		$c->detach();
	}
	$dataset->{'boot'} ||= 1000,
	  $dataset->{'lin_lang_file'} ||= 'lin_lang_stats.xls';
	$dataset->{'sca_ofile'} ||= "Significant_genes.csv";
	unless ( -f $path . "createPvalues.R" ) {
		my $script =
		    "source('libs/Tool_PValues.R')\nload('analysis.RData')\n"
		  . "stat_obj <- create_p_values( data, boot = $dataset->{'boot'}, "
		  . "lin_lang_file= '$dataset->{'lin_lang_file'}', sca_ofile ='$dataset->{'sca_ofile'}' )\n"
		  . "save( data, file='analysis.RData' )\n";
		open( OUT, ">" . $path . "createPvalues.R" ) or die "$!\n";
		print OUT $script;
		close(OUT);
	}
	chdir($path);
	system(
'/bin/bash -c "DISPLAY=:7 R CMD BATCH --no-save --no-restore --no-readline -- createPvalues.R >> R.run.log"'
	);
	return $dataset;
}

__PACKAGE__->meta->make_immutable;

1;
