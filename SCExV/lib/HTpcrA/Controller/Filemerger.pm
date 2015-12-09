package HTpcrA::Controller::Filemerger;

use Moose;
use HTpcrA::EnableFiles;
use namespace::autoclean;
use DateTime::Format::MySQL;
use strict;
use warnings;

with 'HTpcrA::EnableFiles';

#BEGIN { extends 'HTpcrA::base_db_controler';};
BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Genexpress_catalist::Controller::Figure - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

sub index : Path : Form {
	my ( $self, $c, @args ) = @_;
	my $path = $self->path($c);
	$c->form->method('post');
	$c->cookie_check();
	$c->model('Menu')->Reinit();
	$c->form->field(
		'comment'  => 'PCR or FACS data?',
		'name'     => 'datatype',
		'options'  => [ 'PCR', 'FACS' ],
		'value'    => 'PCR',
		'required' => 1,
	);
	$c->form->field(
		'comment'  => 'new filename',
		'name'     => 'name',
		'value'    => 'MergedFile.xls',
		'required' => 1,
	);

	$c->form->field(
		'comment'  => 'The files to be merged',
		'name'     => 'source',
		'type'     => 'file',
		'required' => 1,
	);
	$c->form->field(
		'comment'  => 'Evaluate Pass/Fail information',
		'name'     => 'use_pass_fail',
		'options'  => [ 'True', 'False' ],
		'value'    => 'True',
		'required' => 1,
	);

	if ( $c->form->submitted ) {
		my $dataset = $self->__process_returned_form($c);

		$self->R_script( $c, $dataset );

		unless ( -f $path . "$dataset->{'name'}" ) {
			$c->stash->{'ERROR'} =
			  ["There has been an error during the file creation!"];
			open( IN, "<$path/FileMerger.Rout" );
			$c->stash->{'message'} = join( "</br>", <IN> );
			close(IN);
		}
		else {
			open( OUT, "<" . $path . "$dataset->{'name'}" );
			$c->res->header( 'Content-Disposition',
				qq[attachment; filename="$dataset->{'name'}"] );
			while ( defined( my $line = <OUT> ) ) {
				$c->res->write($line);
			}
			close(OUT);

			$c->res->code(204);
			$c->detach();
		}
	}
	$c->form->template( $c->config->{'root'}.'src'. '/form/mergefiles.tt2' );
	$self->file_upload( $c, {});
	$c->stash->{'template'} = 'MergeFiles.tt2';
}

sub R_script {
	my ( $self, $c, $dataset ) = @_;
	my $path = $self->path($c);

	my $script     = "source('libs/Tool_Pipe.R')\ndata<-NULL\n";
	my $r_function = 'read.PCR';
	if ( $dataset->{'datatype'} eq "FACS" ) {
		$r_function = "read.FACS";
	}
	foreach ( @{ $dataset->{'source'} } ) {
		if ( $dataset->{'datatype'} eq "FACS" ) {
			$_ = $self->file_format_fixes( $c, $_, {}, 'facsTable' );
		}
		else {
			$_ = $self->file_format_fixes( $c, $_, {} );
		}
		$script .=
"data <- rbind( data, $r_function ( '$_->{'filename'}', use_pass_fail='$dataset->{'use_pass_fail'}' ) )\n";
	}
	$script .=
	    "rnames <- rownames(data)\n"
	  . "fix <- function (x) { \n"
	  . "x <- as.numeric(x)\n"
	  . "x[which(x<1)] <- 1\n" . "x\n"."}\n"
	  . "data <-  data.frame(apply( data, 2,fix))\n"
#	  . "data <- log10( data )\n"
	  ." rownames(data) <- rnames\n"
	  . "write.table( cbind( Samples = force.absolute.unique.sample(rownames(data)), data ), file='$dataset->{'name'}' , row.names=F, sep='\t',quote=F )\n";

	open( RSCRIPT, ">$path/FileMerger.R" )
	  or Carp::confess(
		"I could not create the R script '$path/FileMerger.R'\n$!\n");
	print RSCRIPT $script;
	chdir($path);
	system(
		'/bin/bash -c "DISPLAY=:7 R CMD BATCH --no-readline -- FileMerger.R"');
	$c->model('scrapbook')->init( $c->scrapbook() )
	  ->Add("<h3>File Merger</h3>\n<i>options:"
		  . $self->options_to_HTML_table($dataset)
		  . "</i>\n" );
	return 1;
}

1;
