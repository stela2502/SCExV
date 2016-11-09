use strict;
use warnings;
use Test::More;
use stefans_libs::root;

BEGIN { use_ok 'HTpcrA::Model::RScript' }

use FindBin;
my $plugin_path = "$FindBin::Bin";

my ( $exp, $value, @values, $tmp, $path );
my $OBJ = HTpcrA::Model::RScript->new();

$path = "$plugin_path/data/Output/";
if ( -f $path . "analysis.RData" ) {
	unlink( $path . "analysis.RData" );
}

@values = split( /\n/, $OBJ->_add_fileRead($path) );

#print "\$exp = ".root->print_perl_var_def(\@values ).";\n";
$exp = ["load( 'norm_data.RData' )"]
  ;    ## the norm_data.RData is read only - no process ever writes to that!
is_deeply( \@values, $exp, "_add_fileRead no file exisits default lock" );

@values = split( /\n/, $OBJ->_add_fileRead( $path, 1 ) );
is_deeply( \@values, $exp, "_add_fileRead no file exisits ignores lock" );

open( OUT, ">$path" . "analysis.RData" )
  or die "I could not create the fake analysis.RData file\n$!\n";
print OUT "FAKE";
close(OUT);

@values = split( /\n/, $OBJ->_add_fileRead($path) );

#print "\$exp = ".root->print_perl_var_def(\@values ).";\n";
$exp = [
	"while ( locked( 'analysis.RData' ) ){Sys.sleep(5)}",
	"set.lock ( 'analysis.RData' )",
	"load( 'analysis.RData' )"
];

is_deeply( \@values, $exp, "_add_fileRead file exisits default lock" );

@values = split( /\n/, $OBJ->_add_fileRead( $path, 1 ) );
is_deeply( \@values, $exp, "_add_fileRead file exisits manual lock" );

@values = split( /\n/, $OBJ->_add_fileRead( $path, 0 ) );
$exp = ["load( 'analysis.RData' )"];
is_deeply( \@values, $exp, "_add_fileRead file exisits manual no lock" );

my $c = test::c->new();

@values = split(
	/\n/,
	$OBJ->create_script(
		$c,
		'analyze',
		{
			'UG'             => 'none',
			'plotsvg'        => 0,
			'zscoredVioplot' => 'T',
			'cluster_by'     => 'Expression',
			'mds_alg'        => 'PCA',
			'cluster_alg'    => 'ward.D2',
			'GeneUG'         => 'none',
			'cluster_type'   => 'hierarchical clust',
			'cluster_amount' => 5,
			'cluster_on'     => 'MDS',
			'K'              => 2,
		}
	)
);

#print "\$exp = " . root->print_perl_var_def( \@values ) . ";\n";

$exp = [
	'options(rgl.useNULL=TRUE)',
	'library(Rscexv)',
	'useGrouping<-NULL',
	"while ( locked( 'analysis.RData' ) ){Sys.sleep(5)}",
	"set.lock ( 'analysis.RData' )",
	"load( 'analysis.RData' )",
	'groups.n <- 5',
	'move.neg <- FALSE',
	'plot.neg <- FALSE',
	'beanplots = FALSE',
	'plotsvg = 0',
	'zscoredVioplot = T',
	"onwhat='Expression'",
"data <- analyse.data ( data, groups.n=groups.n, onwhat='Expression', clusterby='MDS',"
	  . " mds.type='PCA', cmethod='ward.D2', LLEK='2', ctype= 'hierarchical clust', "
	  . " zscoredVioplot = zscoredVioplot, move.neg = move.neg, plot.neg=plot.neg, beanplots=beanplots, "
	  . "plotsvg =plotsvg, useGrouping=useGrouping )",
	'',
	'saveObj( data )'
];

is_deeply( \@values, $exp, "analysis script" );

@values = split(
	/\n/,
	$OBJ->create_script(
		$c,
		'run_RF_local',
		{
			'k'                    => 5,
			'Numer of Trees'       => 40,
			'Numer of Forests'     => 15,
			'Number of Used Cells' => 300,
		}
	)
);

print "\$exp = " . root->print_perl_var_def( \@values ) . ";\n";
$exp = [
	'options(rgl.useNULL=TRUE)',
	'library(Rscexv)',
	'useGrouping<-NULL',
	'while ( locked( \'analysis.RData\' ) ){Sys.sleep(5)}',
	'set.lock ( \'analysis.RData\' )',
	'load( \'analysis.RData\' )',
	'subset = 300',
	'if ( subset + 20 > nrow(data@data)) {subset = nrow(data@data) - 20}',
'data <- rfCluster(data, rep = 1, SGE = F, email=\'none@nowhere.de\',  subset = subset, k = 5, nforest = , ntree = , slice = 2 )',
	'saveObj(data)', 'run = 1', 'while ( run ) {',
'   try( { data <- rfCluster(data, rep = 1, SGE = F, email=\'none@nowhere.de\',  subset = subset, k = 5, nforest = , ntree = , slice = 2 ) } )',
'   if ( length(data@usedObj$rfObj[[\'Rscexv_RFclust_1\']]@distRF) != 0 ) {',
	'      run = 0', '   }', '   else {', '      Sys.sleep(20)', '   }',
	'}',
	'while ( locked( \'analysis.RData\' ) ){Sys.sleep(5)}',
	'set.lock ( \'analysis.RData\' )', 'load( \'analysis.RData\' )',
'data <- rfCluster(data, rep = 1, SGE = F, email=\'none@nowhere.de\',  subset = subset, k = 5, nforest = , ntree = , slice = 2 )'
	,
	'saveObj( data )'
];

is_deeply( \@values, $exp, "RandomForest script" );

done_testing();

#print "\$exp = ".root->print_perl_var_def($value ).";\n";

package test::c;
use strict;
use warnings;

use FindBin;

sub new {
	my $self = {
		'config' => {
			'ncore'      => 4,
			'calcserver' => {
				'ncore'   => 32,
				'ip'      => '127.0.0.1',
				'subpage' => "/weblog/fluidigm/"
			}
		  }

	};
	bless $self, shift;
	return $self;
}

sub session_path {
	my $p = "$FindBin::Bin" . "/data/Output/";
	unless ( -d $p ) {
		mkdir($p);
	}

	return $p;
}

sub config {    ## Catalyst function
	return shift->{'config'};
}

sub model {     ## Catalyst function
	my ( $self, $name ) = @_;
	return {};

}

sub uri_for {
	my $str = shift;
	return "http://localhost/$str";
}

sub get_session_id {    ## Catalyst function
	return 1234556778;
}

1;

