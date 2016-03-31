package HTpcrA::Controller::Files;

use Moose;
use HTpcrA::EnableFiles;
use namespace::autoclean;
use DateTime::Format::MySQL;
use JSON;
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

sub use_example_data : Local : Form {
	my ( $self, $c, @args ) = @_;

	$c->model('Menu')->Reinit();
	$c->cookie_check();
	system( 'rm -R ' . $c->session_path() );

	$c->session->{'PCRTable'}  = [];
	$c->session->{'PCRTable2'} = [];
	$c->session->{'facsTable'} = [];

	my $path = $self->path($c);

	my $example_path = "$path../../../example_data";
	system("cp $example_path/*.csv $path../");
	my $dataset = {
		'normalize2' => 'none',
		'negContr'   => undef,
		'orderKey'   => 'Array',
		'rmGenes'    => 'NO',
		'userGroup' =>
		  'an integer list of group ids in the same order as the table(s)',
		'nullCT'   => 1,
		'PCRTable' => [
			map { root->filemap( $path . "../" . $_ ) } 'PCR Array1.csv',
			'PCR Array2.csv',
			'PCR Array3.csv'
		],
		'facsTable' => [
			map { root->filemap( $path . "../" . $_ ) } 'Array1 Index sort.csv',
			'Index sort Array2.csv',
			'Index sort Array3.csv'
		],
		'maxGenes'      => 'any',
		'maxCT'         => '25',
		'use_pass_fail' => 'True',
	};
	$self->file_upload( $c, $dataset );
	$self->R_script( $c, $dataset );
	$c->res->redirect( $c->uri_for("/files/upload/") );
	$c->detach();
}

sub renew_rlib : Local {
	my ( $self, $c, @args ) = @_;
	my $path = $c->session_path();
	my $root = $c->config->{'root'};
	system( "cp $root/R_lib/Tool* $path" . "libs/" );
	$c->res->redirect( $c->uri_for("/analyse/re_run/") );
	$c->detach();
}

sub download_example_data : Local : Form {
	my ( $self, $c, @args ) = @_;
	my $path     = $self->path($c);
	my $filename = "$path../../../example_data/SCExV_example_data.zip";
	open( OUT, "<$filename" )
	  or Carp::confess(
"Sorry, but I could not access the file '$filename' on the server!\n$!\n"
	  );
	$c->res->header( 'Content-Disposition',
		qq[attachment; filename="SCExV_example_data.zip"] );
	while ( defined( my $line = <OUT> ) ) {
		$c->res->write($line);
	}
	close(OUT);
	$c->res->code(204);
}

sub update_form {
	my ( $self, $c, $hide_most ) = @_;

	#$self->{'form_array'} = [];
	$hide_most ||= 0;
	$c->form->method('post');
	my $hash = $self->config_file( $c, 'Preprocess.Configs.txt' );
	$hash->{'rmGenes'} ||= 'NO';
	my @genes;

	push(
		@{ $self->{'form_array'} },
		{
			'comment'  => 'Upload the PCR results table',
			'name'     => 'PCRTable',
			'type'     => 'file',
			'required' => 0,
		}
	);
	push(
		@{ $self->{'form_array'} },
		{
			'comment'  => 'Upload the PCR results table',
			'name'     => 'PCRTable2',
			'type'     => 'file',
			'required' => 0,
			'multiple' => 1,
		}
	);
	push(
		@{ $self->{'form_array'} },
		{
			'comment'  => 'Key Word to sort the files',
			'name'     => 'orderKey',
			'value'    => $hash->{'orderKey'} || 'Array',
			'required' => 1,
		}
	);
	push(
		@{ $self->{'form_array'} },
		{
			'comment'  => 'Upload the FACS results table',
			'name'     => 'facsTable',
			'type'     => 'file',
			'required' => 0,
			'multiple' => 1,
		}
	);
	push(
		@{ $self->{'form_array'} },
		{
			'comment' => 'Normalization method',
			'name'    => 'normalize2',
			'value'   => $hash->{'normalize2'},
			'type'    => 'select',
			'options' => [
				'max expression',
				'median expression',
				'mean control genes',
				'quantile',
				'none'
			],
			'value'    => 'none',
			'required' => 0,
		}
	);
	push(
		@{ $self->{'form_array'} },
		{
			'comment'  => 'Evaluate Pass/Fail information',
			'name'     => 'use_pass_fail',
			'options'  => [ 'True', 'False' ],
			'value'    => $hash->{'use_pass_fail'} || 'True',
			'required' => 0,
		}
	);
	push(
		@{ $self->{'form_array'} },
		{
			'comment' => 'User defined Grouping',
			'name'    => 'userGroup',
			'value' =>
			  'an integer list of group ids in the same order as the table(s)',
			'required' => 0,
		}
	);
	push(
		@{ $self->{'form_array'} },
		{
			'comment' => 'Max control genes',
			'name'    => 'maxGenes',
			'type'    => 'select',
			'options' => [ 'any', 'more than 1', 'more than 2', 'all 4' ],

			#	'options'  => [0,1,2,3 ],
			'required' => 0,
			'value'    => $hash->{'maxGenes'} || 'any',
		}
	);
	push(
		@{ $self->{'form_array'} },
		{
			'comment'  => 'expression above CT value',
			'name'     => 'maxCT',
			'type'     => 'text',
			'value'    => $hash->{'maxCT'} || 25,
			'required' => 0,
		}
	);
	push(
		@{ $self->{'form_array'} },
		{
			'comment'  => 'set not expressed genes (Ct=999) to MAX(Ct) +',
			'name'     => 'nullCT',
			'type'     => 'text',
			'value'    => $hash->{'nullCT'} || 1,
			'required' => 0,
		}
	);
	my $path = $self->path($c);
	opendir( DIR, $path );
	my @files = sort grep( !/_Heatmap.png/, grep ( /\.png$/, readdir(DIR) ) );
	closedir(DIR);
	my @tmp =
	  $self->create_selector_table_4_figures( $c, 'mygallery', 'pictures1',
		'controlG1', @files );

	splice( @tmp, 1, 1 );    ## kick out the select box!
	$c->form->name('mygallery');
	my $str;

#$hash->{ 'negContr'} = [$hash->{ 'negContr'}] unless ( ref($hash->{ 'negContr'}) eq "ARRAY" );
	push(
		@{ $self->{'form_array'} },
		{
			'comment'  => 'Negative control genes',
			'name'     => 'negContr',
			'value'    => $hash->{'negContr'},
			'options'  => $self->{'select_options'},
			'required' => 0,
			'multiple' => 1,
			'jsclick' =>
'if ( userInformedOnNegControls===0) {alert("WARNING: All cells expressing a negative control gene will be dropped.");userInformedOnNegControls=1;}',
		}
	);

	foreach my $i ( 1 .. 4 ) {
		$str = $tmp[0];
		$hash->{ 'controlG' . $i } ||= '';
		if ( $hash->{ 'controlG' . $i } =~ m/.png$/ ) {
			$str .= "</td>
</tr>
<tr>
<td width='100%'><p align='center'><img src='"
			  . $hash->{ 'controlG' . $i }
			  . "', width='100%' id='pictures$i'></td>
</tr>
</table>
";
		}
		else {
			$str .= "</td>
</tr>
<tr>
<td width='100%'><p align='center'><img src='"
			  . $c->uri_for('/static/images/Empty_selection.png')
			  . "' width='100%' id='pictures$i'></td>
</tr>
</table>
";
		}

		$c->stash->{ 'GOI_' . $i } = $str;

		push(
			@{ $self->{'form_array'} },
			{
				'comment'  => 'Positive control gene ' . $i,
				'name'     => 'controlG' . $i,
				'value'    => $hash->{ 'controlG' . $i },
				'options'  => $self->{'select_options'},
				'required' => 0,
				'jsclick' =>
				  "showimage('mygallery', 'pictures$i','controlG$i')",
			}
		);
	}

	foreach ( @{ $self->{'form_array'} } ) {
		$c->form->field( %{$_} );
	}
	$c->form->submit( [ 'Apply', 'Done here -> Analyze' ] );
}

sub report_last {
	my ( $self, $c ) = @_;
	my $hash = $self->config_file( $c, 'Preprocess.Configs.txt' );
	## return the text describing all performed steps!
	my $text = '';
	return $text;
}

sub control_page : Local : Form {
	my ( $self, $c, @args ) = @_;

	my $path = $self->check($c,'nothing');

	opendir( DIR, $path );
	my @files = sort grep ( /\.png$/, readdir(DIR) );
	closedir(DIR);
	my @tmp =
	  $self->create_selector_table_4_figures( $c, 'mygallery', 'pictures',
		'picture', @files );

	$c->stash->{'histograms'} = join( "\n", @tmp );

	$c->stash->{'boxplot'} = join(
		"\n",
		$self->create_selector_table_4_figures(
			$c, 'mygallery2', 'pictures2', 'picture',
			"boxplot_filtered_samples.svg",
			"boxplot_filtered_zscored_samples.svg"
		)
	);

	$c->stash->{'heatmap'} = join(
		"\n",
		$self->create_selector_table_4_figures(
			$c,
			'mygallery3',
			'pictures3',
			'picture',
			"Contr_filtered_inverted_norm_Heatmap.svg",
			"Contr_filtered_inverted_norm_Zscore_Heatmap.svg"
		)
	);

	$self->Script( $c,
		    '<script type="text/javascript" src="'
		  . $c->uri_for('/scripts/figures.js')
		  . '"></script>' );
	$c->stash->{'template'} = 'control_page.tt2';
}

sub ajaxuploader : Local : Form {
	my ( $self, $c, @args ) = @_;
	$c->form->method('post');
	$c->form->field(
		'type'     => 'file',
		'name'     => 'PCR',
		'value'    => '',
		'options'  => '',
		'required' => 0,
	);
	$c->form->field(
		'type'     => 'file',
		'name'     => 'FACS',
		'value'    => '',
		'options'  => '',
		'required' => 0,
	);

	my $dataset = $self->__process_returned_form($c);
	Carp::confess( root->print_perl_var_def($dataset) );

	$c->res->redirect( $c->uri_for("/files/upload/") );
	$c->detach();
}

sub upload : Local : Form {
	my ( $self, $c, @args ) = @_;
	my $path = $self->path($c);
	$self->update_form($c);
	$self->file_upload($c);
	$c->model('Menu')->Reinit();
	$c->cookie_check();


	if ( $c->form->submitted ) {
		if (   $c->form->submitted() eq "Apply"
			|| $c->form->submitted() eq "Upload Data" )
		{    ## the second is added using pure HTML in the form definition!
			my $main_path = $c->session_path();
			foreach ( "norm_data.RData", "R.error" ) {
				unlink( $main_path . $_ )
				  if ( -f $main_path . $_ );
			}
			system("rm -Rf $path*");
			eval { system("rm ../Grouping*") };

			my $dataset = $self->__process_returned_form($c);
			$self->config_file( $c, 'Preprocess.Configs.txt', $dataset );
			$self->file_upload( $c, $dataset );
			$self->R_script( $c, $dataset );
			unless ( -f $c->session_path(). "norm_data.RData" ) {
				Carp::confess("File ".$c->session_path(). "norm_data.RData". " Not found"  );
				if ( defined @{ $dataset->{'negControllGenes'} }[0] && length(@{ $dataset->{'negControllGenes'} }[0]) > 0 ) {
					my $spath = $c->session_path();
					open( OUT, ">" . $spath . "Error_system_message.txt" );
					print OUT
"<h3>The file upload did not produce a usable dataset</h3> 
You have selected at least one negative control gene which is likely have lead to the dropping of all cells.  
Please re-upload your files without selecting negative controle gene(s).";
					close OUT;
					open( OUT, ">" . $spath . "back_to.txt" );
					print OUT
					  '/files/upload/';    ## uri_for call on the error page
					close(OUT);
					$c->res->redirect( $c->uri_for("/error/error/") );
					$c->detach();
				}
				elsif ( -f $path . "/R_file_read_error.txt" ) {
					open( IN, "<" . $path . "/R_file_read_error.txt" );
					$c->stash->{ERROR} = [<IN>];
					while (<IN>) {
						if ( $_ =~ m/file ..\/(.+) not readable / ) {
							$c->stash->{'message'} .= $_;
							$self->remove_file_from_cockie( $c, $1 );
						}
						$c->stash->{'message'} .= $_;
					}
					close(IN);
				}
				else {
					## this does mean, that no file could be uploaded
					$c->stash->{'ERROR'} =
					    "Sorry, an error in the file upload occured. "
					  . "Please check if your files are supported, or try loading each one individually "
					  . "to identify the problematic file "
					  . "<a href='#' onclick=\"MyWindow=window.open('"
					  . $c->uri_for('/help/index/files/upload/PCRTable/')
					  . "','MyWindow', 'width=500,heig‌​ht=500'); return false;\" >"
					  . "<img style='border:0px;' src='/static/images/Questions.gif' width='20px'></a>"
					  . ". <a href='"
					  . $c->uri_for("/error/error")
					  . "'>Full error message...</a>";
					$self->init_file_cookie( $c, 1 );
					$self->file_upload($c);
					my $spath = $c->session_path();
					system( "cp $path/Preprocess.Rout "
						  . $spath
						  . "Error_system_message.txt" );
				}
			}
			$self->update_form($c);
		}
		elsif ( $c->form->submitted() eq "Done here -> Analyze" ) {
			$c->res->redirect( $c->uri_for("/analyse/run_first/") );
			$c->detach();
		}
	}

	$self->update_form($c);

	$self->Script( $c,
		    '<script type="text/javascript" src="'
		  . $c->uri_for('/scripts/figures.js')
		  . '"></script>' . "\n"
		  . '<script type="text/javascript" src="'
		  . $c->uri_for('/scripts/upload.js')
		  . '"></script>' );

	$c->form->template( $c->config->{'root'}.'src'. '/form/upload.tt2' );

	$c->stash->{'template'} = 'file_upload.tt2';
}

sub remove_file_from_cockie {
	my ( $self, $c, $filename ) = @_;
	my $session_hash = $c->session();
	foreach my $filetype ( 'PCRTable', 'facsTable' ) {
		my ($index) = grep {
			@{ $session_hash->{$filetype} }[$_]->{'filename'} eq $filename
		} 0 .. @{ $session_hash->{$filetype} } - 1;
		my $kicked = splice( @{ $session_hash->{$filetype} }, $index, 1 );
	}
	return 1;
}

sub path {
	my ( $self, $c ) = @_;

	#return $self->{'_path_'} if ( $self->{'_path_'} );
	my $r = $c->session_path() . "preprocess/";
	mkdir("$r") unless ( -d $r );

	#$self->{'_path_'} = $r;
	return $r;
}

sub R_script {
	my ( $self, $c, $dataset ) = @_;
	my $path = $self->path($c);
	$dataset->{'controlM'} = [];

	## new R approach in version 0.20
	## Use pure R
	#Carp::confess( $dataset->{'controlG1'} );
	foreach ( 1 .. 4 ) {
		if ( $dataset->{ 'controlG' . $_ } ) {
			$dataset->{ 'controlG' . $_ } =~ m/preprocess\/(.+).png/;
			if ( !$1 eq "" ) {
				$dataset->{ 'controlG' . $_ } = $1;
				push( @{ $dataset->{'controlM'} }, $1 );
			}
		}
	}
	$dataset->{'negControllGenes'} =
	  [ map { $_ =~ m/preprocess\/(.+).png/; $1; }
		  @{ $dataset->{'negContr'} } ];

	my $seesion_hash = $c->session();
	$dataset->{'maxGenes'} = 0 if ( $dataset->{'maxGenes'} eq "any" );
	$dataset->{'maxGenes'} = 3 if ( $dataset->{'maxGenes'} eq "all 4" );
	$dataset->{'maxGenes'} = $1
	  if ( $dataset->{'maxGenes'} =~ m/more than (\d)/ );

	#Carp::confess ( root->print_perl_var_def( $seesion_hash->{'PCR'} ) );

	my $script = $c->model('RScript')->create_script()
	  . "negContrGenes <- NULL\n";
	$script .=
	  "negContrGenes <- c ( '"
	  . join( "', '", @{ $dataset->{'negControllGenes'} } ) . "')\n"
	  if ( defined @{ $dataset->{'negControllGenes'} }[0] );
	
	$script .= "data.filtered <- createDataObj ( PCR= c( " 
	  . join(", ", 
	  	map { "'$_->{'filename'}'" } @{ $seesion_hash->{'PCRTable'} } ) 
	  . " ), "
	  . "FACS= c( '"
	  . join( "','",
		map { "'$_->{'filename'}'" } @{ $seesion_hash->{'facsTable'} } )
	  . "' ), "
	  . "ref.genes= c( '"
	  . join( "', '", @{ $dataset->{'controlM'} } ) . "' ),"
	  . " use_pass_fail = '$dataset->{'use_pass_fail'}', "
	  . "max.value=40, max.ct= $dataset->{'maxCT'} , max.control=$dataset->{'maxGenes'}, "
	  . "norm.function='$dataset->{'normalize2'}', negContrGenes=negContrGenes )\n"
	  . "save( data.filtered, file=file.path(data.filtered\@outpath,'norm_data.RData') )\n";
	$script =~ s/c\( '.?.?\/?' \)/NULL/g;
	
	$c->model('RScript')->runScript( $c, $c->session_path(), 'Preprocess.R', $script, 1 );
	
	$c->model('scrapbook')->init( $c->scrapbook() )
	  ->Add("<h3>File Upload</h3>\n<i>options:"
		  . $self->options_to_HTML_table($dataset)
		  . "</i>\n" );
	return 1;
}

sub normalize_flui_R {
	my ( $self, $dataset ) = @_;
	my $script = '';
	if ( $dataset->{'normalize2'} eq "max expression" ) {
		$script .= "#normalize to the max expression value in each cell\n"
		  . "PCRTable.d.red.norm <- ( apply(PCRTable.d.red,1,min) - PCRTable.d.red )\n";
	}
	elsif ( $dataset->{'normalize2'} eq "mean control genes" ) {
		if ( @{ $dataset->{'controlM'} } > 0 ) {
			$script .=
			  "#normalize to the mean expression value of the control genes \""
			  . join( '", "', @{ $dataset->{'controlM'} } ) . "\"\n"
			  . "mean.control <- function (x) {mean(x[is.na(match(colnames(PCRTable.d.red), c('"
			  . join( "','", @{ $dataset->{'controlM'} } )
			  . "') ))==F] ) }\n"
			  . "PCRTable.d.red.norm <- ( apply(PCRTable.d.red,1,mean.control) - PCRTable.d.red )\n";
		}
		if ( @{ $dataset->{'controlM'} } == 1 ) {
			$script .=
"#NOT normalized(!) just invert the values so that high values == high expression\n"
			  . "PCRTable.d.red.norm <- PCRTable.d.red.norm[,is.na(match(colnames(PCRTable.d.red.norm),'@{$dataset->{'controlM'}}[0]' ) )==T]\n"
			  . "system ( 'echo \"I have removed the control gene @{$dataset->{'controlM'}}[0] from the analysis as it has been used to normalize and therefore does not contain any more data.\" >> R.error')\n";
		}
	}
	elsif ( $dataset->{'normalize2'} eq "quantile" ) {
		$script .=
		    "##Quantil norm on samples\n"
		  . $self->R_functs()
		  . "PCRTable.d.red.norm <- t(rank.normalize(t(PCRTable.d.red)))\n"
		  . "colnames(PCRTable.d.red.norm) <- colnames(PCRTable.d.red)\n"
		  . "rownames(PCRTable.d.red.norm) <- rownames(PCRTable.d.red)\n"
		  . "PCRTable.d.red.norm <- ( max(PCRTable.d.red) - PCRTable.d.red )\n";
	}
	if ( $script eq "" ) {
		## default to (global max) - value
		$script .=
		  "PCRTable.d.red.norm <- ( max(PCRTable.d.red) - PCRTable.d.red )\n";
	}
	return $script;

	#sdbaegbreg
}

sub index : Local {
	my ( $self, $c, @filename ) = @_;
	my $filename = '/' . join( "/", @filename );
	my $fn       = @filename[ @filename - 1 ];
	my $allowed  = $c->session_path();

	unless ( $filename =~ m/^\/?$allowed/ ) {
		$c->response->body(
"No way you are allowed to access the file $filename - sorry! ($allowed)"
		);
		$c->detach();
	}
	open( OUT, "<$filename" )
	  or Carp::confess(
"Sorry, but I could not access the file '$filename' on the server!\n$!\n"
	  );
	$c->res->content_type('image/svg+xml') if ( $filename =~ m/svg$/ );
	$c->res->header( 'Content-Disposition', qq[attachment; filename="$fn"] );
	while ( defined( my $line = <OUT> ) ) {
		$c->res->write($line);
	}
	close(OUT);

	$c->res->code(204);
}

sub message_form {
	my ( $self, $c, @args ) = @_;
	$self->{'form_array'} = [];
	$c->form->name('LBform');
	push(
		@{ $self->{'form_array'} },
		{
			'name'  => 'text',
			'type'  => 'textarea',
			'cols'  => 80,
			'rows'  => 20,
			'value' => '',
		}
	);
	push(
		@{ $self->{'form_array'} },
		{
			'name'  => 'filename',
			'value' => $self->NOW(),
		}
	);
	$c->form->medthod('post');
	$c->form->jsfunc('submitForm();');

	$self->Script(
		$c,
		'<script language="JavaScript" type="text/javascript" src="'
		  . $c->uri_for("/rte/")
		  . 'html2xhtml.min.js"></script>
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
text.html = "";
text.build();
}
//-->
</script>
<noscript><div id="content"><p><b><span style="color:red">Javascript must be enabled to use this form.</span></b></p></div></noscript>
	'
		  . "<SCRIPT LANGUAGE=\"JavaScript\"><!--\n"
		  . "setTimeout('document.test.submit()',5000);\n"
		  . "//--></SCRIPT>\n"
	);

	foreach ( @{ $self->{'form_array'} } ) {
		$c->form->field( %{$_} );
	}
}

sub report_error : Local : Form {
	my ( $self, $c, @args ) = @_;
	$c->session_path();
	$self->message_form($c);
	$self->check($c, 'nothing');
	
	$self->{'form_array'} = [];
	push(
		@{ $self->{'form_array'} },
		{
			'name'  => 'text',
			'type'  => 'textarea',
			'cols'  => 80,
			'rows'  => 20,
			'value' => '',
		}
	);
	foreach ( @{ $self->{'form_array'} } ) {
		$c->form->field( %{$_} );
	}
	if ( $c->form->submitted && $c->form->validate ) {
		my $dataset = $self->__process_returned_form($c);
		if ( $dataset->{'text'} =~ m/\w/ ) {
			open( OUT, ">", $c->session_path() . "ErrorLog.txt" );
			print OUT $dataset->{'text'};
			close(OUT);
		}
		my $filename = 'Error_report_' . $self->NOW() . '.zip';
		system(
			"cd " . $c->session_path() . "\nrm *.zip\nzip -9 -r $filename *" );
		system( "mv "
			  . $c->session_path()
			  . "$filename "
			  . $c->session_path()
			  . "../" );
		if ( -f '/usr/local/bin/report_SCExV_error.pl' ) {
			system( '/usr/local/bin/report_SCExV_error.pl -error_file '
				  . $c->session_path()
				  . "../$filename" );
		}
		$c->res->redirect( $c->uri_for("/files/upload/") );
		$c->detach();
	}

	#$c->form->template(
	#	$c->config->{'root'}.'src'. '/form/MakeLabBookEntry.tt2' );
	$c->stash->{'template'} = 'report_error.tt2';
}

sub as_zip_file : Local : Form {
	my ( $self, $c, @args ) = @_;
	$self->message_form($c);
	$self->check($c, 'upload');

	if ( $c->form->submitted && $c->form->validate ) {
		my $dataset = $self->__process_returned_form($c);
		my $path    = $c->session_path();
		if ( $dataset->{'text'} =~ m/\w/ ) {

#Carp::confess (  $c->model('MethodsSection') -> html_methods($c, "<h1>User Description:</h1>\n\n".$dataset->{'text'}."\n\n") );
			open( OUT, ">", $c->session_path() . "MyDescription.html" );
			print OUT $c->model('MethodsSection')->html_methods( $c,
				    "<h1>User Description:</h1>\n\n"
				  . $dataset->{'text'}
				  . "\n\n" );
			close(OUT);
		}
		$self->session_file( $c, 'save' );
		$dataset->{'filename'} .= ".zip"
		  unless ( $dataset->{'filename'} =~ m/\.zip$/ );
		$dataset->{'filename'} =~ s/\s+/_/g;
		my $filename = $dataset->{'filename'};
		system(
			"cd " . $path . "\nrm *.zip\nzip -9 -r '$filename' * .internals" );
		my $table = $self->md5_table( $path . "../" );
		$table->AddDataset(
			{
				@{ $table->{'header'} }[0] => $filename,
				@{ $table->{'header'} }[1] =>
				  $self->file2md5str( $path . $filename )
			}
		);
		$self->md5_table( $path . "../", $table );
		$c->res->redirect(
			$c->uri_for( "/files/index" . $path . "$filename" ) );
		$c->detach();
	}
	$c->form->template(
		$c->config->{'root'}.'src'. '/form/MakeLabBookEntry.tt2' );
	$c->stash->{'template'} = 'download_all.tt2';
}

sub session_file {
	my ( $self, $c, $what ) = @_;
	my $path = $c->session_path();
	my $json = JSON->new;
	if ( $what eq 'save' ) {
		my $json_text = $json->encode( $c->session() );
		mkdir( $path . ".internals" ) unless ( -d $path . ".internals" );
		open( OUT, ">" . $path . ".internals/session.json" );
		print OUT $json_text;
		close(OUT);
	}
	elsif ( $what eq 'load' ) {
		open( IN, "<" . $path . ".internals/session.json" )
		  or Carp::confess( "I can not read from the file '"
			  . $path
			  . ".internals/session.json'\n$!\n" );
		my $str = join( "", <IN> );

		#Carp::confess($path.".internals/session.json\n". $str );
		my $session = $json->decode($str);
		foreach my $problem (qw(PCRTable facsTable)) {
			foreach ( @{ $session->{$problem} } ) {
				$_->{'path'}  = $path;
				$_->{'total'} = $path . $_->{'filename'};
			}
		}
		map {
			unless ( $_ eq 'path' || $_ =~ m/^__/ ) {
				$c->session->{$_} = $session->{$_};
			}
		} keys %$session;

		close(IN);
	}
	return 1;
}

sub start_from_zip_file : Local : Form {
	my ( $self, $c, @args ) = @_;
	$c->form->method('post');
	$c->model('Menu')->Reinit();
	$self->{'form_array'} = [];
	push(
		@{ $self->{'form_array'} },
		{
			'comment'  => 'Upload the zip file',
			'name'     => 'zipfile',
			'type'     => 'file',
			'required' => 1,
		}
	);

	if ( $c->form->submitted && $c->form->validate ) {
		my $dataset = $self->__process_returned_form($c);
		my $path    = $c->session_path();
		## check whether I want to read in this file!
#Carp::confess ( root::get_hashEntries_as_string( @{$dataset->{ 'zipfile' }}[0]->{'filename'} , 3, "PROBLEMS WITH THE UPLOADED ZIP FILE?"));
		if ( -f $path . @{ $dataset->{'zipfile'} }[0]->{'filename'} ) {

#Carp::confess ( "cd $path && unzip -o @{$dataset->{ 'zipfile' }}[0]->{'filename'}" );
			my $table = $self->md5_table( $path . "../" );
			my $hash = $table->GetAsHash( @{ $table->{'header'} }[ 0, 1 ] );
			my $md5 =
			  $self->file2md5str(
				$path . @{ $dataset->{'zipfile'} }[0]->{'filename'} );
			unless (
				defined $hash->{ @{ $dataset->{'zipfile'} }[0]->{'filename'} } )
			{
				$c->session->{'error'} =
				  "Sorry, that file is not supported</br>Possible problems:<ul>"
				  . "<li>You downloaded the file before this feature was added to the server</li>"
				  . "<li>You changed the filename of the file</li>"
				  . "Either way I am sorry - you need to re-start the analysis at <a href='"
				  . $c->uri_for('/files/upload/')
				  . "'>the file upload section</a>";
				$c->res->redirect( $c->uri_for("/files/error") );
				warn "filename (A) '"
				  . @{ $dataset->{'zipfile'} }[0]->{'filename'}
				  . "' '$md5'\n";
				$c->detach();
			}
			unless (
				$hash->{ @{ $dataset->{'zipfile'} }[0]->{'filename'} } eq $md5 )
			{
				$c->session->{'error'} =
				  "Sorry, that file is not supported</br>Possible problems:<ul>"
				  . "<li>You have changed the contents of the file</li>"
				  . "This is a potential security risk and therefore not allowed - you need to re-start the analysis at <a href='"
				  . $c->uri_for('/files/upload/')
				  . "'>the file upload section</a>";
				$c->res->redirect( $c->uri_for("/files/error") );
				warn "filename (B) '"
				  . @{ $dataset->{'zipfile'} }[0]->{'filename'}
				  . "' '$md5'\n";
				$c->detach();
			}
			system(
"cd $path && unzip -o '@{$dataset->{ 'zipfile' }}[0]->{'filename'}'"
			);
			$self->session_file( $c, 'load' );
			$c->res->redirect( $c->uri_for("/analyse/index/") );
			$c->detach();
		}
		else {
			Carp::confess(
				root::get_hashEntries_as_string(
					$dataset->{'zipfile'}, 3,
					"PROBLEMS WITH THE UPLOADED ZIP FILE?"
				)
			);
		}
	}
	$c->stash->{'message'} =
"Here you can upload a zip file you previousely downloaded from this server <p>"
	  . "</p>You must not change the file in any way before uploading it to the server! "
	  . "In addition each server keeps its own log of downloaded files - so you can not use a file downloaded from a different server.</p>";
	foreach ( @{ $self->{'form_array'} } ) {
		$c->form->field( %{$_} );
	}
	$c->stash->{'template'} = 'message.tt2';

}

sub error : Path {
	my ( $self, $c, @args ) = @_;
	$c->stash->{'error'}    = $c->session->{'error'} || "No error message";
	$c->session->{'error'}  = undef;
	$c->stash->{'template'} = 'message.tt2';
}

sub file2md5str {
	my ( $self, $filename ) = @_;
	my $md5_sum = 0;
	if ( -f $filename ) {
		open( FILE, "<$filename" );
		binmode FILE;
		my $ctx = Digest::MD5->new;
		$ctx->addfile(*FILE);
		$md5_sum = $ctx->b64digest;
		close(FILE);
	}
	return $md5_sum;
}

sub md5_table {
	my ( $self, $path, $data_table ) = @_;
	my $process_id;
	if ( ref($data_table) eq "data_table" ) {
		$process_id = "save file";
		$data_table->write_file( $path . "md5_hashes.xls" );
	}
	else {
		$data_table = data_table->new();
		if ( -f $path . "md5_hashes.xls" ) {
			$process_id = "read file";
			$data_table->read_file( $path . "md5_hashes.xls" );
		}
		else {
			$process_id = "new file";
			$data_table->Add_2_Header( [ 'filename', 'md5sum' ] );
		}
	}
	return $data_table;
}

sub preprocessing : Local {
	my ( $self, $c ) = @_;
	$c->res->redirect(
		$c->uri_for(
			"/files/index" . $c->session_path() . "preprocess/Preprocess.R"
		)
	);
	$c->detach();
}

sub analysis_script : Local {
	my ( $self, $c ) = @_;
	unless ( -f "/files/index" . $c->session_path() . "RScript.R" ) {
		$c->flash->{'message'} =
"Sorry there is no analyis script available - please submit the form first!\n";
		$c->res->redirect( $c->uri_for("/analyse/") );
		$c->detach();
	}
	$c->res->redirect(
		$c->uri_for( "/files/index" . $c->session_path() . "RScript.R" ) );
	$c->detach();
}

sub NOW {
	return join(
		"_",
		split(
			/[\s:]+/,
			DateTime::Format::MySQL->format_datetime(
				DateTime->now()->set_time_zone('Europe/Berlin')
			)
		)
	);
}

sub CanvasMatrix : Local {
	my ( $self, $c ) = @_;
	## make the CanvasMatrix.js available!
	open( OUT, "<" . $c->session->{'path'} . "CanvasMatrix.js" )
	  or Carp::confess(
"Sorry, but I could not access the file '/tmp/webGL/CanvasMatrix.js' on the server!\n"
	  );
	$c->res->header( 'Content-Disposition',
		qq[attachment; filename="CanvasMatrix.js"] );
	while ( defined( my $line = <OUT> ) ) {
		$c->res->write($line);
	}
	close(OUT);
	$c->res->code(204);
}

1;
