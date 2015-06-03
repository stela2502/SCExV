#! /usr/bin/perl
use strict;
use warnings;
use Test::More tests => 7;
BEGIN { use_ok 'stefans_libs::GeneGroups::R_table' }

use FindBin;
my $plugin_path = "$FindBin::Bin";

my ( $value, @values, $exp, $tmp );
my $stefans_libs_GeneGroups_R_table = stefans_libs::GeneGroups::R_table->new(
	{ 'filename' => $plugin_path . "/data/2D_data.xls" } );
is_deeply(
	ref($stefans_libs_GeneGroups_R_table),
	'stefans_libs::GeneGroups::R_table',
	'simple test of function stefans_libs::GeneGroups::R_table -> new()'
);


$tmp = stefans_libs::GeneGroups::R_table->new();

#print "\$exp = ".root->print_perl_var_def( {'data' => $tmp->__split_line( '"some text" "1 2 3 4" "some other text"' ), 'usage info' =>   $tmp->{'use'} } ).";\n";
$exp = {
	'data'       => [ 'some text', '1 2 3 4', 'some other text' ],
	'usage info' => [
		'0', '0', 'use', '0', '0', '0', 'use', '0',
		'0', '0', 'use', '0', 'split'
	]
};

is_deeply(
	{
		'data' => $tmp->__split_line('"some text" "1 2 3 4" "some other text"'),
		'usage info' => $tmp->{'use'}
	},
	$exp,
	"'some text', '1 2 3 4', 'some other text'"
);



$tmp = stefans_libs::GeneGroups::R_table->new();

#print "\$exp = ".root->print_perl_var_def( {'data' => $tmp->__split_line( '"some text" 1 2 3 4 "some other text"' ), 'usage info' =>   $tmp->{'use'} } ).";\n";
$exp = {
  'usage info' => [ '0', '0', 'use', '0', 'split', '0', 'use', '0' ],
  'data' => [ 'some text', '1', '2', '3', '4', 'some other text' ]
};

is_deeply(
	{
		'data' => $tmp->__split_line('"some text" 1 2 3 4 "some other text"'),
		'usage info' => $tmp->{'use'}
	},
	$exp,
	"'some text',1,2,3,4,'some other text'"
);


$tmp = stefans_libs::GeneGroups::R_table->new();

#print "\$exp = ".root->print_perl_var_def( {'data' => $tmp->__split_line( '"some text" 1 2 3 4 "some other text"' ), 'usage info' =>   $tmp->{'use'} } ).";\n";
$exp = {
  'usage info' => [ '0', '0', 'use', '0', 'split' ],
  'data' => [ 'some text', '1', '2', '3', '4' ]
};

is_deeply(
	{
		'data' => $tmp->__split_line('"some text" 1 2 3 4'),
		'usage info' => $tmp->{'use'}
	},
	$exp,
	"'some text',1,2,3,4"
);




#print "\$exp = " . root->print_perl_var_def( [$stefans_libs_GeneGroups_R_table->{'header'}, @{$stefans_libs_GeneGroups_R_table->{'data'}}[0..4] ] )  . ";\n";
$exp = [
	[ 'Samples', 'V1', 'V2' ],
	[ '1', '-9.87374311241638e-13', '-1.15126731690709' ],
	[ '2', '0.139411312225804',     '-1.25154752516175' ],
	[ '3', '-3.2839496673248e-12',  '-1.15126731690397' ],
	[ '4', '5.0522198059573e-14',   '-1.15126731690858' ],
	[ '5', '-3.11119295357717e-12', '-1.15126731690417' ],
];
is_deeply( [$stefans_libs_GeneGroups_R_table->{'header'},  @{ $stefans_libs_GeneGroups_R_table->{'data'} }[ 0 .. 4 ] ],
	$exp, 'MDS results read in' );

my $color = stefans_libs::GeneGroups::R_table->new(
	{ 'filename' => $plugin_path . "/data/2D_data_color.xls" } );

#print "\$exp = " . root->print_perl_var_def( [$color->{'header'}, @{$color->{'data'}}[0..4] ] )  . ";\n";
$exp = [
	[ 'Samples', 'red', 'green', 'blue', 'colorname' ],
	[ 'sc_39.P0', '255', '0', '0', '#FF0000FF' ],
	[ 'sc_3.P0',  '255', '0', '0', '#FF0000FF' ],
	[ 'sc_1.P0',  '255', '0', '0', '#FF0000FF' ],
	[ 'sc_33.P0', '255', '0', '0', '#FF0000FF' ],
	[ 'sc_6.P0',  '255', '0', '0', '#FF0000FF' ]
];

is_deeply( [$color->{'header'}, @{ $color->{'data'} }[ 0 .. 4 ] ], $exp, 'color results read in' );

unlink -f $plugin_path . "/data/Output/2Dplot.png"  if ( -f $plugin_path . "/data/Output/2Dplot.png" );

$stefans_libs_GeneGroups_R_table->plotXY_fixed_Colors( $plugin_path . "/data/Output/2Dplot.png", 'V1', 'V2', $color );

ok ( -f $plugin_path . "/data/Output/2Dplot.png" , "created the figure file '$plugin_path/data/Output/2Dplot.png'");

unlink -f $plugin_path . "/data/Output/2Dplott_no_extra_color.png"  if ( -f $plugin_path . "/data/Output/2Dplott_no_extra_color.png" );
$stefans_libs_GeneGroups_R_table->plotXY( $plugin_path . "/data/Output/2Dplot_no_extra_color.png", 'V1', 'V2', $stefans_libs_GeneGroups_R_table );
ok ( -f $plugin_path . "/data/Output/2Dplot.png" , "created the figure file '$plugin_path/data/Output/2Dplot_no_extra_color.png'");
#print "\$exp = ".root->print_perl_var_def(\@values ).";\n";
