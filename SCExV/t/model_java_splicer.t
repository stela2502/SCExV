use strict;
use warnings;
use Test::More;
use stefans_libs::root;
use Digest::MD5 qw(md5_hex);

BEGIN { use_ok 'HTpcrA::Model::java_splicer' }

use FindBin;
my $plugin_path = "$FindBin::Bin";

my $obj = HTpcrA::Model::java_splicer->new();
ok( ref($obj) eq 'HTpcrA::Model::java_splicer', "right object" );
my $str = join( "\n",
	'Something useless at the start',
	'<script id="some crap">',
	'with absolutely no script in it',
	'</script>',
	'<script>',
	'this is the last',
	'</script>',
	'And some unrelated after...' );
my $hashA = $obj->java_splice_old($str);

print "\$exp = " . root->print_perl_var_def($hashA) . ";\n";

my $exp = {
	'md5sums' => [
		'c4de8a301e9fc66d76019cd1ee48d77e', # '867890511b6cbdb85e3926e11e48d123'
	],
	'functions' => [
		'<script id="some crap">
with absolutely no script in it
</script>
',   
#'<script>
#this is the last
#</script>
#'
	],
	'rest' => 'Something useless at the start
And some unrelated after...'
};

is_deeply( $hashA, $exp, "old match" );

## first start with the old rgl scripts
open( IN, "<" . $plugin_path . "/data/oldRGL/points.html" ) or die $!;
$hashA = $obj->java_splice_old( join( "", <IN> ) );
close(IN);
open( IN, "<" . $plugin_path . "/data/oldRGL/density.html" ) or die $!;
my $hashB = $obj->java_splice_old( join( "", <IN> ) );
close(IN);

my (@values) = $obj->read_webGL( $plugin_path . "/data/oldRGL/points.html" );

#print "\$exp = ".root->print_perl_var_def( \@values ).";\n";
$values[0] = &md5_hex( $values[0] );

$exp = [ 'e8c2c5247fb46b605d45dbe2e88a7bda', 'rgl.start();' ];

is_deeply( \@values, $exp, "read_webGL" );

## create an up to date rgl output
open( Rscript, ">" . $plugin_path . "/data/oldRGL/createNew.R" );
print Rscript join(
	"\n",
	"options(rgl.useNULL=TRUE)", "library(rgl)",
	"with(iris, plot3d(Sepal.Length, Sepal.Width, Petal.Length,",
	"  type='s', col=as.numeric(Species)))",
"try(writeWebGL( width=470, height=470, dir = '$plugin_path/data/oldRGL/webGLNEW'),silent=F)"
	,
);
close(Rscript);

system( "R CMD BATCH $plugin_path/data/oldRGL/createNew.R" );
@values = $obj->classSplitter(  $plugin_path . "/data/oldRGL/webGLNEW/index.html" );
ok($values[0] =~m/CanvasMatrix4/, "the first script is the CanvasMatrix4\n");
ok ($values[1] =~ m/rgltimerClass/, "The second script is the RGL class\n");
$values[0] = &md5_hex( $values[0] );
$values[1] = &md5_hex( $values[1] );
#print "\$exp = ".root->print_perl_var_def( \@values ).";\n";

$exp = [ '6840972719708e702645e440d992daec', '8d9120db4d23e0b5dabf57a1077091d1' ];
is_deeply( \@values, $exp, "classSplitter with rgl version 0.96.0 " );

my ( $fileA, $onloadA ) = $obj->getDIV( $plugin_path . "/data/oldRGL/webGLNEW/index.html" );

open( Rscript, ">" . $plugin_path . "/data/oldRGL/createNewK.R" );
print Rscript join(
	"\n",
	"options(rgl.useNULL=TRUE)", "library(rgl)",
	"with(iris, plot3d(Sepal.Length, Sepal.Width, Petal.Length,",
	"  type='s', col=as.numeric(Species)))",
"try(writeWebGL( width=470, height=470, dir = '$plugin_path/data/oldRGL/webGLNEWK', prefix='K',
template= system.file(file.path('densityWebGL.html'), package = 'Rscexv')  ),silent=F)"
	,
);
close(Rscript);

system( "R CMD BATCH $plugin_path/data/oldRGL/createNewK.R" );

my ( $fileB, $onloadB ) = $obj->getDIV( $plugin_path . "/data/oldRGL/webGLNEWK/index.html" );


$fileA = join("\n", map { if ( $_ =~m/"material"/){ '';} else { $_ }} split ( "\n", $fileA) );
$fileB = join("\n", map { if ( $_ =~m/"material"/){ '';} else { $_ }} split ( "\n", $fileB) );
#print "\$exp = ".root->print_perl_var_def( [ $fileA, $fileB ]  ).";\n";
$exp = [ '<div id="div" class="rglWebGL"></div>
<script type="text/javascript">
	var div = document.getElementById("div"),
      rgl = new rglwidgetClass();
  div.width = 470;
  div.height = 470;
  rgl.initialize(div,

  rgl.prefix = "";
</script>

</div>', '<div id="Kdiv" class="rglWebGL"></div>
<script type="text/javascript">
	var Kdiv = document.getElementById("Kdiv"),
      Krgl = new rglwidgetClass();
  Kdiv.width = 470;
  Kdiv.height = 470;
  Krgl.initialize(Kdiv,

  Krgl.prefix = "K";
</script>

</div>' ];

is_deeply( [ $fileA, $fileB ], $exp, "The right rgl div elements with rgl version 0.96.0" );
done_testing();
