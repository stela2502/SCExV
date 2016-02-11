package HTpcrA::Model::rgl3dplots;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Model';

=head1 NAME

HTpcrA::Model::rgl3dplots - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.


=encoding utf8

=head1 AUTHOR

root

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

This model is a fix to the discontinued writeWebGL() functionallity in R.

=cut

__PACKAGE__->meta->make_immutable;

sub updateRGLjs {
	my ( $self, $c, @args) = @_;
	my $path = $c->session_path();
	open ( OUT, ">".$path."testRGL.R" ) or die "could not create file $path"."testRGL.R\n".$!;
	print OUT "
	library('rgl')
	library(rglwidget)
	library(htmlwidgets)
	options(rgl.useNULL=TRUE)
	example('plot3d', 'rgl')
	ret <- rglwidget(elementId='points', width=400, height=400)
	saveWidget(ret, 'test.html', selfcontained = FALSE)
	";
	close ( OUT );
	{
	chdir($path);
	system(
'/bin/bash -c "R CMD BATCH --no-save --no-restore --no-readline -- testRGL.R > R.run.log"'
	);
	}
	#now move all javascript and css files into the right position.
	my $files = {map { $_ => 1} $self->_cp_files($path."test_files/", $path."../../" )};
	foreach ( 'htmlwidgets.js', 'rgl.css', 'rglClass.src.js', 'CanvasMatrix.src.js', 'rglWebGL.js'  ){
		Carp::confess( "important rglwidget file not found: $_" ) unless ( $files->{$_} );
	}
	return 1;
}

sub _cp_files {
	my ( $self, $path, $to_base ) = @_;
	opendir ( DIR, $path ) or Carp::confess ("Could not open lib path $path\n$!");
	my @files;
	foreach ( grep { ! /^\./ } readdir(DIR) ) {
		if ( -d $path.$_ ) {
			push ( @files, $self->_cp_files( $path.$_."/", $to_base ));
		}else{
			if ( $_ =~ m/\.js$/ ){
				system ( "cp $path$_ $to_base"."scripts/");
				push ( @files, $_ );
			}elsif ( $_ =~ m/\.css$/ ){
				system ( "cp $path$_ $to_base"."css/");
				push ( @files, $_);
			}
		}
	}
	return @files;
}

=head2 process_rgl_html ( <file> )
returns the data specific html including two div elements. 
The inner one contains the 3D canvas and is named threeD or kernel.
=cut
 
sub process_rgl_html{
	my ( $self, $file ) = @_;
	open ( IN, "<$file" ) or Carp::confess ( "Could not read $file\n$!");
	my $use = 0;
	my $ret = '';
	while ( <IN> ) {
		$use = 1 if ( $_ =~ m/htmlwidget_container/);
		$use = 0 if ( $_ =~ m/\/body/ );
		$ret .= $_ if ( $use);
	}
	return $ret;
}


1;
