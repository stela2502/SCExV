#! /usr/bin/perl
use strict;
use warnings;
use Test::More tests => 12;
BEGIN { use_ok 'stefans_libs::file_readers::help_data' }

use FindBin;
my $plugin_path = "$FindBin::Bin";

my ( $value, @values, $exp );
my $obj = stefans_libs::file_readers::help_data->new();
is_deeply(
	ref($obj),
	'stefans_libs::file_readers::help_data',
	'simple test of function stefans_libs::file_readers::help_data -> new()'
);

$obj->read_file( $plugin_path . "/data/help_strings.txt" );
$value = { map { $_ => $obj->{$_} } keys %$obj };

#print "\$exp = " . root->print_perl_var_def($value->{'index'}) . ";\n";

$exp = {
	'file' => $plugin_path . "/data/help_strings.txt",
	'index' => {
  'analyseindexmds_alg' => '10',
  'analyseindexcluster_amount' => '11',
  'analyseindexcluster_alg' => '9',
  'analyseindexcluster_by' => '8',
  'filesuploadfacsTable' => '1',
  'filesuploadcontrolGenes' => '6',
  'filesuploadPCRTable' => '0',
  'analyseindexUG' => '13',
  'analyseindexK' => '12',
  'analyseindexcluster_on' => '7',
  'filesuploadrmGenes' => '3',
  'filesuploadmaxGenes' => '5',
  'filesuploaduserGroup' => '4',
  'filesuploadnormalize2' => '2'
},
	'data' => {'files' => {
		'upload' => {
			'controlGenes' => 'Explain how to select the control genes',
			'rmGenes' =>
			  'What does the remove genes (none expressed) option mean?',
			'maxGenes' =>
'Explain the option to remove samples where the control genes are not expressed.',
			'userGroup'  => 'This is not used at the moment - do not bother!',
			'normalize2' => 'Help 4 the normalization options',
			'PCRTable' => 'Help 4 the PCR tables',
			'facsTable'     => 'Help 4 the FACS'
		}
	},
	'analyse' => {
		'index' => {
			'cluster_by' =>
'If you provided FACS data you can select to cluster the samples based on the FACS expression values or FACS MDS data.'
			  . ' If you only provided us with PCR data this option is ignored.',
			'cluster_amount' =>
'You can specify the number of groups you want to separate the data into.'
			  . ' The MDS plot should give you a hint on whether you should increase or reduce this number.',
			'cluster_alg' =>
'Internally the R hclust method is used. This are the clustering options provided by this function.'
			  . ' Please read the <a href="http://stat.ethz.ch/R-manual/R-patched/library/stats/html/hclust.html" target="_blank">R documentation '
			  . 'for the hclust function</a> for more information.',
			'mds_alg' =>
'Select the <b>m</b>ulti<b>d</b>imensional <b>s</b>caling algorithm that should be used for this analysis. '
			  . 'PUT IN 3 LINKS TO PUBMED TO DESCRIBE THE OPTIONS ',
			'cluster_on' =>
'Please select the data set to apply the non supervised clustering to - the data you provided (Expression data)'
			  . ' or the MDS data. (Ignored if you select a user defined grouping)',
			'K' =>
'This option is only important for the LLE and ISOMAP mds analysis. Low numbers speed up the analysis.',
			'UG' =>
			  'Here you can select one of the previously created groupings. '
			  . 'The plate ID is automatically created during the upload process.'
			  . ' All other groupings are based on gene expression differences (<a href="/gene_group/" '
			  . 'target="_blank">based on one gene</a> or <a href="/grouping_2d/index/" target="_blank" >based on two genes</a>. '
			  . 'You need to reload the analysis page to show new groups.'
		}
	},
	}
};

is_deeply( $exp, $value, 'read OK' );

foreach (keys %{$exp->{'data'}->{'analyse'}->{'index'}} ) {
	is_deeply(
	$obj->HelpText( 'analyse', 'index', $_ ),
	$exp->{'data'}->{'analyse'}->{'index'}->{$_},
	"$_ text"
);
} 
system ( "cp $plugin_path/data/help_strings.txt $plugin_path/data/Output/help_strings.xls");
$obj->{'file'} = $plugin_path . "/data/Output/help_strings.xls";
ok($obj-> AddData( 'files', 'upload', 'testNew', 'this is a totally useless pice of information' ), 'Add a new description' );

is_deeply($obj->HelpText( 'files', 'upload', 'testNew'),'this is a totally useless pice of information' ,"data really added and available" );

#print "\$exp = ".root->print_perl_var_def($value ).";\n";
