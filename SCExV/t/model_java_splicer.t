use strict;
use warnings;
use Test::More;
use stefans_libs::root;
BEGIN { use_ok 'HTpcrA::Model::java_splicer' }

use FindBin;
my $plugin_path = "$FindBin::Bin";


my $obj = HTpcrA::Model::java_splicer->new();
ok ( ref($obj) eq 'HTpcrA::Model::java_splicer' , "right object" );

my $hashA = $obj -> java_splice_old ( join("\n",'Something useless at the start', '<script id="some crap">', 'with absolutely no script in it','</script>','<script>', 'this is the last', '</script>', 'And some unrelated after...' ) );
#print "\$exp = ".root->print_perl_var_def( $hashA ).";\n";
my $exp = {
  'md5sums' => [ 'c4de8a301e9fc66d76019cd1ee48d77e', '867890511b6cbdb85e3926e11e48d123' ],
  'functions' => [ '<script id="some crap">
with absolutely no script in it
</script>
', '<script>
this is the last
</script>
' ],
  'rest' => 'Something useless at the start
And some unrelated after...'
};

is_deeply($hashA, $exp, "old match OK" );

## first start with the old rgl scripts
open ( IN, "<".$plugin_path."/data/oldRGL/points.html") or die $!;
$hashA = $obj -> java_splice_old ( join("",<IN>) );
close ( IN );
open ( IN, "<".$plugin_path."/data/oldRGL/density.html") or die $!;
my $hashB = $obj -> java_splice_old ( join("",<IN>) );
close ( IN );

my ( $funcA, $uniqueB, $duplicates ) = $obj->drop_duplicates( $hashA, $hashB, 1 );

die "Uniques B:\n$uniqueB\n\nduplicates:\n$duplicates\n";



my $java = "<script>
rglwidgetClass = function() {
    this.canvas = null;
    this.userMatrix = new CanvasMatrix4();
    this.types = [];
    this.prMatrix = new CanvasMatrix4();
    this.mvMatrix = new CanvasMatrix4();
    this.vp = null;
    this.prmvMatrix = null;
    this.origs = null;
    this.gl = null;
    this.scene = null;
};

(function() {
    this.multMV = function(M, v) {
        return [ M.m11 * v[0] + M.m12 * v[1] + M.m13 * v[2] + M.m14 * v[3],
                 M.m21 * v[0] + M.m22 * v[1] + M.m23 * v[2] + M.m24 * v[3],
                 M.m31 * v[0] + M.m32 * v[1] + M.m33 * v[2] + M.m34 * v[3],
                 M.m41 * v[0] + M.m42 * v[1] + M.m43 * v[2] + M.m44 * v[3]
               ];
    };

    this.vlen = function(v) {
		  return Math.sqrt(this.dotprod(v, v));
		};

    this.dotprod = function(a, b) {
      return a[0]*b[0] + a[1]*b[1] + a[2]*b[2];
    }

		this.xprod = function(a, b) {
			return [a[1]*b[2] - a[2]*b[1],
			    a[2]*b[0] - a[0]*b[2],
			    a[0]*b[1] - a[1]*b[0]];
		};

    this.cbind = function(a, b) {
      return a.map(function(currentValue, index, array) {
            return currentValue.concat(b[index]);
      });
    };

    this.swap = function(a, i, j) {
      var temp = a[i];
      a[i] = a[j];
      a[j] = temp;
    };

    this.flatten = function(a) {
      return [].concat.apply([], a);
    };

    /* set element of 1d or 2d array as if it was flattened.  Column major, zero based! */
    this.setElement = function(a, i, value) {
      if (Array.isArray(a[0])) {
        var dim = a.length,
            col = Math.floor(i/dim),
            row = i % dim;
        a[row][col] = value;
      } else {
        a[i] = value;
      }
    };

    this.transpose = function(a) {
      var newArray = [],
          n = a.length,
          m = a[0].length,
          i;
      for(i = 0; i < m; i++){
        newArray.push([]);
      }

      for(i = 0; i < n; i++){
        for(var j = 0; j < m; j++){
          newArray[j].push(a[i][j]);
        }
      }
      return newArray;
    };

    this.sumsq = function(x) {
      var result = 0, i;
      for (i=0; i < x.length; i++)
        result += x[i]*x[i];
      return result;
    };
}";

my $value = $obj->java_splice ( $java );

#print "\$exp = ".root->print_perl_var_def( $value ).";\n";

is_deeply ( [ split( "\n", join("",@{$value->{'functions'}}))], [split("\n",$java)], "function unchanged!" );


my $tmp =  $obj->java_splice ( $java );

is_deeply ( $value, $tmp, "function works reproducible" );

$value = $obj->drop_duplicates ( $java, $java );

#is_deeply ( [ split( "\n", $value)], [split("\n",$java)], "all duplicated dropped!" );

$value = $obj->drop_duplicates ( $java, "Something else in the second String A!\n".$java."\nSomething else in the second String B!"  );

#is_deeply ( [ split( "\n", $value)], [split("\n",$java. "\nSomething else in the second String A!\nSomething else in the second String B!")], "all duplicated dropped, but differences kept!" );

## real world example

my ($fileA, $fa_onload ) = $obj->read_webGL ( $plugin_path."/data/splice_java_A.html" );

my ($fileB, $fb_onload) = $obj->read_webGL ( $plugin_path."/data/splice_java_B.html" );

my $html_head=     "<html><head>
        <TITLE>RGL model</TITLE>
    </head>
    <body onload='$fa_onload$fb_onload'>\n";
    
my ( $full, $partA, $partB, $scriptA, $scriptB );
( $full, $partB, $scriptB ) = $obj->drop_duplicates ( $fileA, $fileB );

( $full, $partA, $scriptA ) = $obj->drop_duplicates ( $fileB, $fileA );

is_deeply( [split("\n",$scriptA )], [split("\n",$scriptB )], "both dropped parts are the same" );

open ( OUT ,">".$plugin_path."/data/Output/PartB.txt") or die $!;
print OUT  $partB;
close OUT;
open ( OUT , ">".$plugin_path."/data/Output/rgl.js" ) or die $!;
print OUT $scriptA;
close ( OUT );
$html_head .='<script type="text/javascript" src="./rgl.js"></script>'."\n";

open ( OUT ,">".$plugin_path."/data/Output/deduplicated_AB.html") or die $!;
print OUT $html_head. $partA. $partB. "</body>\n</html>";
close ( OUT );


open ( OUT ,">".$plugin_path."/data/Output/merged_AB.html") or die $!;
print OUT $html_head.$fileA. $fileB. "</body>\n</html>";
close ( OUT );

#print $value;
done_testing();

#print "\$exp = ".root->print_perl_var_def(\@values ).";\n";

