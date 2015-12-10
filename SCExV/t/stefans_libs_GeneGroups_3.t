#! /usr/bin/perl
use strict;
use warnings;
use Test::More tests => 12;
BEGIN { use_ok 'stefans_libs::GeneGroups' }

use FindBin;
my $plugin_path = "$FindBin::Bin";

my ( $value, @values, $exp );
my $stefans_libs_GeneGroups = stefans_libs::GeneGroups->new();
is_deeply( ref($stefans_libs_GeneGroups),
	'stefans_libs::GeneGroups',
	'simple test of function stefans_libs::GeneGroups -> new()' );

my $test_table = stefans_libs::GeneGroups::R_table->new();
is_deeply(
	ref($test_table),
	'stefans_libs::GeneGroups::R_table',
	'simple test of function stefans_libs::GeneGroups::R_table -> new()'
);
$test_table->Add_2_Header( [ 'Sample', 'gA', 'gB', 'gC', 'gD' ] );

$test_table->{'data'} = [
	[ 'A1', -0.93, +0.9,   -0.98, -0.98 ],
	[ 'A2', -0.92, +0.98,  -0.9,  -0.9 ],
	[ 'A3', -0.91, +0.87,  -0.87, -0.87 ],
	[ 'B1', 0.98,  0.87,   -0.61, -0.61, ],
	[ 'B2', 0.87,  0.9,    -0.33, -0.33, ],
	[ 'B3', 0.9,   0.97,   -0.78, -0.5, ],
	[ 'C1', 0.1,   0.2,    -0.2,  -0.5, ],
	[ 'C2', 0.3,   0.4,    -0.15, -0.5, ],
	[ 'C3', 0.2,   0.4,    0.1,   0.1, ],
	[ 'D1', -0.87, -0.93,  0.43,  0.43 ],
	[ 'D2', -0.74, -0.92,  0.56,  0.56 ],
	[ 'D3', -0.90, -0.91,  0.61,  0.61 ],
	[ 'E1', 0.98,  -0.93,, 0.81,  0.81 ],
	[ 'E2', 0.87,  -0.92,, 0.90,  0.90 ],
	[ 'E3', 0.9,   -0.91,  0.78,  0.78 ],
];

mkdir( $plugin_path . '/data/Output/' )
  unless ( -d $plugin_path . '/data/Output/' );
$test_table->line_separator("\t");
$test_table->write_file( $plugin_path . '/data/Output/TestTable.xls' );
$test_table->line_separator('"?\s"?');
ok( -f $plugin_path . '/data/Output/TestTable.xls',
	"The data file is present" );
unlink( $plugin_path . '/data/Output/noG_gA_gB.png' )
  if ( -f $plugin_path . '/data/Output/noG_gA_gB.png' );
my ( $xaxis, $yaxis ) =
  $test_table->plotXY( $plugin_path . '/data/Output/noG_gA_gB.png',
	'gA', 'gB', $stefans_libs_GeneGroups );
ok(
	-f $plugin_path . '/data/Output/noG_gA_gB.png',
	"plotXY() '$plugin_path/data/Output/noG_gA_gB.png"
);

#is_deeply ( {$xaxis => $xaxis, $yaxis => $yaxis }, $exp, "Axes created as expected" );

$test_table->plotXY( $plugin_path . '/data/Output/noG_gC_gD.png',
	'gC', 'gD', $stefans_libs_GeneGroups );

$stefans_libs_GeneGroups->AddGroup( 'gA', 'gB', -1,  -0.5, 0.5, 1 );
$stefans_libs_GeneGroups->AddGroup( 'gA', 'gB', 0.5, 1,    0.5, 1 );

$stefans_libs_GeneGroups->AddGroup( 'gA', 'gB', -1, -0.5, -0.5, -1 );
$stefans_libs_GeneGroups->AddGroup( 'gA', 'gB', 1,  0.5,  -0.5, -1 );
$stefans_libs_GeneGroups->write_grouping(
	$plugin_path . '/data/Output/grouping.txt' );

my $GGset = $stefans_libs_GeneGroups->group4( 'gA', 'gB' );

ok( $GGset->match_2_group( -0.9, 0.9,  1 ), 'match group 1' );
ok( $GGset->match_2_group( 0.9,  0.9,  2 ), 'match group 2' );
ok( $GGset->match_2_group( -0.9, -0.9, 3 ), 'match group 3' );
ok( $GGset->match_2_group( 0.9,  -0.9, 4 ), 'match group 4' );

ok( -f $plugin_path . '/data/Output/grouping.txt',
	'could write file grouping store' );
open( GGI, "<" . $plugin_path . '/data/Output/grouping.txt' );
$exp = [
	"GeneGrouping 0.1\n",
	"markers	gA	gB\n",
	"extends	nothing\n",
	"Gr1	-1	-0.5	0.5	1\n",
	"Gr2	0.5	1	0.5	1\n",
	"Gr3	-1	-0.5	-1	-0.5\n",
	"Gr4	0.5	1	-1	-0.5\n",
];
is_deeply( [<GGI>], $exp, 'right file content grouping.txt' );
close(GGI);
$stefans_libs_GeneGroups->{'data'} = $test_table;
$stefans_libs_GeneGroups->{'data_file'} =
  $plugin_path . '/data/Output/TestTable.xls';
$value = $stefans_libs_GeneGroups->group_samples( 'gA', 'gB' );

$exp = {
	'0' => [ 'C1', 'C2', 'C3' ],
	'3' => [ 'D1', 'D2', 'D3' ],
	'2' => [ 'B1', 'B2', 'B3' ],
	'1' => [ 'A1', 'A2', 'A3' ],
	'4' => [ 'E1', 'E2', 'E3' ],
};

is_deeply( $value, $exp, 'right perl groupng' );

#print "\$exp = ".root->print_perl_var_def( {%{$stefans_libs_GeneGroups}} ).";\n";
#print "\$exp = ".root->print_perl_var_def( { data=>{%{$stefans_libs_GeneGroups->{'data'}}}} ).";\n";
#print "\$exp = ".root->print_perl_var_def( { "GS 'gA gB'" =>{%{$stefans_libs_GeneGroups->{'GS'}->{'gA gB'}}}} ).";\n";

my $fname = $plugin_path . '/data/Output/grouping.R';
unlink($fname) if ( -f $fname );
$stefans_libs_GeneGroups->write_R( $plugin_path . '/data/Output/grouping.R',
	'testObj' );
ok( -f $fname, "Created file '$fname'" );

$fname = $plugin_path . '/data/Output/RScript.R';
unlink($fname) if ( -f $fname );
open( RS, ">" . $fname ) or die "I could not create the test R script!\n$!\n";
print RS
"source ('$plugin_path/../root/R_lib/Tool_grouping.R')\nsetwd('$plugin_path/data/Output/')\ntestObj <- list ( 'PCR' = read.delim('TestTable.xls', row.names=1))\nsource ('grouping.R')\nwrite.table(userGroups, 'R_result.txt', sep='\t', quote=F)\n";
close(RS);

#warn ( 'R CMD BATCH --no-save --no-restore --no-readline -- '. $plugin_path.'/data/Output/RScript.R' );

$fname = $plugin_path . '/data/Output/R_result.txt';
unlink($fname) if ( -f $fname );
system( 'R CMD BATCH --no-save --no-restore --no-readline -- '
	  . $plugin_path
	  . '/data/Output/RScript.R' );
ok( -f $fname, "Created file '$fname'" )
  or system("cat $plugin_path/data/Output/RScript.Rout");

$value = stefans_libs::GeneGroups::R_table->new();
$value->line_separator("\t");
$value->read_file( $plugin_path . '/data/Output/R_result.txt' );

#print "\$exp = ".root->print_perl_var_def( [$value->GetAsHash( 'groupID', 'cellName' )] ).";\n";
$exp = {
	'1' => 'C3',
	'5' => 'E3',
	'4' => 'D3',
	'3' => 'B3',
	'2' => 'A3'
};    ## only the last entry is given back - lasy!

is_deeply( $value->GetAsHash( 'groupID', 'cellName' ),
	$exp, "R results as expected" );

$test_table->plotXY( $plugin_path . '/data/Output/withG_gA_gB.png',
	'gA', 'gB', $stefans_libs_GeneGroups );
$test_table->plotXY( $plugin_path . '/data/Output/withG_gC_gD.png',
	'gC', 'gD', $stefans_libs_GeneGroups );

#system ( "gwenview  $plugin_path/data/Output/withG_gA_gB.png &" );
## coloring using the x and y values is absolutely OK!

my @data = (
	[ 440, 320 ],
	[ 520, 240 ],
	[ 480, 240 ],
	[ 36,  52 ],
	[ 32,  8 ],
	[ 27,  39 ],
	[ 760, 12 ],
	[ 748, 39 ],
	[ 792, 52 ],
	[ 40,  764 ],
	[ 104, 768 ],
	[ 52,  772 ],
	[ 760, 764 ],
	[ 748, 768 ],
	[ 792, 772 ]
);
$exp = [
	[ '0.1',     '0.2' ],
	[ '0.3',     '0.4' ],
	[ '0.2',     '0.4' ],
	[ '-0.91',   '0.87' ],
	[ '-0.92',   '0.98' ],
	[ '-0.9325', '0.9025' ],
	[ '0.9',     '0.97' ],
	[ '0.87',    '0.9025' ],
	[ '0.98',    '0.87' ],
	[ '-0.9',    '-0.91' ],
	[ '-0.74',   '-0.92' ],
	[ '-0.87',   '-0.93' ],
	[ '0.9',     '-0.91' ],
	[ '0.87',    '-0.92' ],
	[ '0.98',    '-0.93' ]
];

@values =
  map { [ $xaxis->pix2value( @$_[0] ), $yaxis->pix2value( @$_[1] ) ] } @data;

is_deeply( \@values, $exp, "translate from x/y ccordinates to values" );

is_deeply( $stefans_libs_GeneGroups->init()->AsString(),
	"GeneGrouping 0.1\n", "init()" );

#print "\$exp = ".root->print_perl_var_def(\@values ).";\n";

