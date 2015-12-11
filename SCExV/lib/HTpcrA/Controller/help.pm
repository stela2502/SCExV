package HTpcrA::Controller::help;
use Moose;
use namespace::autoclean;

with 'HTpcrA::EnableFiles';

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

HTpcrA::Controller::help - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.
=head1 METHODS

=cut

=head2 index

=cut

sub index : Local : Form {
	my ( $self, $c, $controler, $action, $value ) = @_;
	
	unless ( defined $value ) {
		$c->res->redirect($c->uri_for("/default/"));
		$c->detach();
	}
	unless ( $c->model('HelpFile')->controller() ) {
		$c->model('HelpFile')
		  ->read_file( $c->config->{'root'} . "/help/help_strings.xls" );
	}
	my $modify = "";
	if ( $ENV{'CATALYST_DEBUG'} == 1 ){
		$modify = '<a href="'.$c->uri_for('/help/modify/'
		  . join( "/", $controler, $action, $value ))
		  . '">Modify this text</a>' . "\n";
	}
	
	$c->response->body(
		'<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8" />
<title>' . join( " ", $controler, $action, $value ) . '</title>
</head>
<body>
<p>'
		  . $c->model('HelpFile')->HelpText($c, $controler, $action, $value )
		  . '</p>' . "\n" . $modify
		  . '</body>
</html>'
	);
}

sub modify : Local : Form {
	my ( $self, $c, $controler, $action, $value ) = @_;
	unless ( $ENV{'CATALYST_DEBUG'} == 1 ){
		$c->response->body("Service not avaiable  $ENV{'CATALYST_DEBUG'}");
		return;
	}
	unless ( defined $value ) {
		$c->res->redirect($c->uri_for("/default/"));
		$c->detach();
	}
	unless ( $c->model('HelpFile')->controller() ) {
		$c->model('HelpFile')
		  ->read_file( $c->config->{'root'} . "/help/help_strings.xls" );
	}
	my $text = $c->model('HelpFile')->HelpText($c, $controler, $action, $value );
	
	$text =~ s/"/\\"/g;
	my $BODY = '<!DOCTYPE html>
<html>
<head>

	<script language="JavaScript" type="text/javascript" src="'
	  . $c->uri_for("/rte/") . 'html2xhtml.min.js"></script>
    <script language="JavaScript" type="text/javascript" src="'
	  . $c->uri_for("/rte/") . 'richtext_compressed.js"></script>
	
	<script language="JavaScript" type="text/javascript">
<!--
function submitForm() {
	//make sure hidden and iframe values are in sync for all rtes before submitting form
	updateRTEs();
	
	//change the following line to true to submit form
	alert("text = " + htmlDecode(document.RTEDemo.text.value));
	return false;
}

//Usage: initRTE(imagesPath, includesPath, cssFile, genXHTML, encHTML)
initRTE("'
	  . $c->uri_for("/rte/images/") . '", "'
	  . $c->uri_for("/rte/")
	  . '", "", true);

function buildForm() {
	
  //build new richTextEditor 
  var text = new richTextEditor("text");
text.toolbar1         = false;
text.cmdFontName      = false;
text.cmdFontSize      = false;
text.cmdJustifyLeft   = false;
text.cmdJustifyCenter = false;
text.cmdJustifyRight  = false;
text.cmdInsertImage   = false;
text.html = "' . $text . '";
text.build();
}
//-->
</script>
<noscript><div id="content"><p><b><span style="color:red">Javascript must be enabled to use this form.</span></b></p></div></noscript>
	'
	  . "<SCRIPT LANGUAGE=\"JavaScript\"><!--\n"
	  . "setTimeout('document.test.submit()',5000);\n"
	  . "//--></SCRIPT>\n</head>\n<body>\n";

	$c->form->name('LBform');
	$c->form->field(
		'name' => 'text',
		'type' => 'textarea',
		'cols' => 75,
		'rows' => 200,
		'value' =>
		  $c->model('HelpFile')->HelpText( $controler, $action, $value ),
	);
	$c->form->medthod('post');
	$c->form->jsfunc('submitForm();');
	$c->form->template(
		$c->config->{'root'}.'src'. '/form/MakeLabBookEntry.tt2' );
	$BODY .= $c->form->render() . "\n</body>\n</html>\n";

	if ( $c->form->submitted && $c->form->validate ) {
		my $dataset = $self->__process_returned_form($c);
		if ( $dataset->{'text'} =~ m/\w/ ) {
			$dataset->{'text'} =~ s/[\r\n]//g;
			$c->model('HelpFile')
			  ->AddData( $controler, $action, $value, $dataset->{'text'} );
		}
		$c->res->redirect($c->uri_for(
			"/help/index/" . join( "/", $controler, $action, $value ) ));
		$c->detach();
	}
	$c->response->body($BODY);
}

=head1 AUTHOR

Stefan Lang

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
