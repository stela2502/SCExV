package HTpcrA::Controller::Scrapbook;
use stefans_libs::flexible_data_structures::data_table;
use HTpcrA::EnableFiles;
use Moose;
use namespace::autoclean;
use MIME::Base64;

with 'HTpcrA::EnableFiles';

#BEGIN { extends 'HTpcrA::base_db_controler';};
BEGIN { extends 'Catalyst::Controller'; }
use Digest::MD5 qw(md5_hex);

=head1 NAME
HTpcrA::Controller::analyse - Catalyst Controller
=head1 DESCRIPTION
Catalyst Controller.
=head1 METHODS
=cut

=head2 index
=cut

sub index : Local : Form {
	my ( $self, $c, @args ) = @_;
	$self->check($c,'upload');
	my $path = $self->path($c);
	$c->stash->{'scrapbook'} = $c->model('scrapbook')->init( $c->scrapbook() )
	  ->AsString( $c->uri_for( '/files/index/' . $path ) );
	$self->file_upload( $c, {});
	$c->stash->{'template'} = 'ScrapBook.tt2';
}

sub ajaxgroups : Local {
	my ( $self, $c, @args ) = @_;
	opendir( DIR, $c->session_path() );
	$c->res->content_type('application/json');
	opendir( DIR, $c->session_path() );
	$c->res->write(
		"['"
		  . join( "', '",
			'none',
			'Group by plateID',
			grep( /Grouping/, readdir(DIR) ) )
		  . "','$c->session_path()' ]"
	);
	closedir(DIR);
	$c->res->code(204);
	warn $c->res();
}

sub imageadd : Local : Form {
	my ( $self, $c, @args ) = @_;
	$self->check($c,'upload');
	my $path = $self->path($c);

	$c->form->field(
		'type'     => 'textarea',
		'cols'     => 60,
		'rows'     => 20,
		'id'       => 'Caption',
		'name'     => 'Caption',
		'value'    => '',
		'required' => 1,
	);
	my $filemap;

	## identfy the figure file
	if ( !join( "/", @args ) =~ m/$c->get_session_id()/ ) {
		$c->res->redirect(
			$c->uri_for("/help/index/scrapbook/wrong/dataset/") );
		$c->detach();
	}
	else {
		my $do = 1;
		my $tmp;
		while ($do) {
			$tmp = shift(@args);
			$do  = 0 if ( $tmp eq "index" );
			$do  = 0 unless ( defined $tmp );
		}
		if ( @args == 0 ) {
			$c->res->redirect( $c->uri_for("/Not_found/") );
			$c->detach();
		}
		$filemap = root->filemap( join( "/", '', @args ) );
	}
	$c->stash->{'figure'} =
	  $c->uri_for( join( "/", "/files/index", @args ) );

	if ( $c->form->submitted && $c->form->validate ) {
		my $dataset = $self->__process_returned_form($c);
		$c->model('scrapbook')->init( $c->scrapbook() )
		  ->Add( $dataset->{'Caption'}, $filemap->{'total'} );
		$c->res->redirect( $c->uri_for("/scrapbook/index/") );
		$c->detach();
	}

  #$c->form->template( $c->config->{'root'}.'src'. '/form/dropsamples.tt2' );
    $self->file_upload( $c, {});
	$c->stash->{'template'} = 'imageadd.tt2';
}

sub screenshotadd : Local {
	my ( $self, $c, @args ) = @_;
	$self->check($c,'upload');
	my $path = $self->path($c);
	open( IN, "<" . $c->req->body );
	my ( $tag, $data ) = split( ",", join( "\n", <IN> ) );
	close(IN);
	open( OUT, ">" . $path . 'MDS_3D.png' );
	print OUT decode_base64($data);
	close(OUT);
	$c->res->header( "Content-type", "application/json; charset=utf-8" );
	$c->res->write(
		$c->uri_for(
			'/scrapbook/imageadd/files/index/' . $path . 'MDS_3D.png'
		)
	);
	$c->res->code(204);

}

sub textadd : Local : Form {
	my ( $self, $c, @args ) = @_;
	$self->check($c,'nothing');
	my $path = $self->path($c);

	$c->form->field(
		'type'     => 'textarea',
		'cols'     => 60,
		'rows'     => 20,
		'id'       => 'Text',
		'name'     => 'Text',
		'value'    => '',
		'required' => 1,
	);
	if ( $c->form->submitted && $c->form->validate ) {
		my $dataset = $self->__process_returned_form($c);
		$c->model('scrapbook')->init( $c->scrapbook() )
		  ->Add( $dataset->{'Text'} );
		$c->res->redirect( $c->uri_for("/scrapbook/index/") );
		$c->detach();
	}
	$c->stash->{'template'} = 'imageadd.tt2';
}

sub path {
	my ( $self, $c ) = @_;
	my $path = $c->session_path() . "Scrapbook/";
	unless ( -d $path ) {
		mkdir($path);

		system( "touch $path" . "Scrapbook.html" );
	}
	mkdir( $path . "Pictures" ) unless ( -d $path . "Pictures" );
	return $path;
}

sub Javascript {
	return '';
}
1;