#! /usr/bin/perl
use strict;
use warnings;
use Test::More tests => 19;
BEGIN { use_ok 'stefans_libs::GeneGroups' }

use FindBin;
my $plugin_path = "$FindBin::Bin";

my ( $value, @values, $exp );
my $stefans_libs_GeneGroups = stefans_libs::GeneGroups -> new();
is_deeply ( ref($stefans_libs_GeneGroups) , 'stefans_libs::GeneGroups', 'simple test of function stefans_libs::GeneGroups -> new()' );

$stefans_libs_GeneGroups ->read_grouping( $plugin_path.'/data/GeneGroup.txt' );
open ( IN, "<".$plugin_path.'/data/GeneGroup.txt' );
$exp = join("", <IN> );
close ( IN );

print $stefans_libs_GeneGroups->AsString();

is_deeply( [split("\n",$stefans_libs_GeneGroups->AsString( ) )], [ split( "\n",$exp )], 'read == write');

#print $stefans_libs_GeneGroups->export_R( 'PCRTable.d' );

$exp = "userGroups <- data.frame( cellName = rownames(PCRTable.d), userInput = rep.int(1, nrow(PCRTable.d)), groupID = rep.int(1, nrow(PCRTable.d)) )
p1 <- which ( colnames(PCRTable.d) == 'control' )
p2 <- which ( colnames(PCRTable.d) == 'control.1' )
now <- as.vector( which( ( PCRTable.d[,p1] >= -12 & PCRTable.d[,p1] <= -5 ) & ( PCRTable.d[,p2] >= -20 & PCRTable.d[,p2] <= -12 ) ))
userGroups\$userInput[now] = 'control control.1 -12 -5 -20 -12'
userGroups\$groupID[now] = 2
now <- as.vector( which( ( PCRTable.d[,p1] >= -12 & PCRTable.d[,p1] <= -6 ) & ( PCRTable.d[,p2] >= -5 & PCRTable.d[,p2] <= 0 ) ))
userGroups\$userInput[now] = 'control control.1 -12 -6 -5 0'
userGroups\$groupID[now] = 3\n";

is_deeply( [split("\n",$stefans_libs_GeneGroups->export_R('PCRTable.d' ) )], [ split( "\n",$exp )], 'export_R');

## now add the groups from scratch!
$stefans_libs_GeneGroups = stefans_libs::GeneGroups -> new();

ok ($stefans_libs_GeneGroups->AddGroup('control', 'control.1', -12, -5, -20, -12 ) == 1, 'Add first group' );
ok ($stefans_libs_GeneGroups->AddGroup('control', 'control.1', -12, -6, -5, 0 ) == 2, 'Add second group' );

is_deeply( [split("\n",$stefans_libs_GeneGroups->export_R('PCRTable.d' ) )], [ split( "\n",$exp )], 'manual group adding');

## read the R dataset

my $data_table = $stefans_libs_GeneGroups->read_data( $plugin_path.'/data/PCRTable.data' );
#print "\$exp = ".root->print_perl_var_def($data_table->get_line_asHash(0) ).";\n";
$exp = {
  'Gfi1' => '-24.8095738732685',
  'Epor' => '-26.2971569330385',
  'Rbl1' => '-26.2971569330385',
  'ki67' => '-26.2971569330385',
  'Rbl2' => '-23.3090497880293',
  'Ikzf1' => '-26.2971569330385',
  'Esam1' => '-26.2971569330385',
  'p19' => '-22.7762986332947',
  'Ccnb2' => '-26.2971569330385',
  'p16' => '-26.2971569330385',
  'Cited2' => '-3.638545864259',
  'Tal1' => '-26.2971569330385',
  'Ccna2' => '-26.2971569330385',
  'control' => '-0.490993558045101',
  'p27' => '-12.6855227572822',
  'Cd150' => '-26.2971569330385',
  'Mpl' => '-26.2971569330385',
  'Hoxa5' => '-24.2927985995864',
  'Mpo' => '-23.4159491975925',
  'Cd34' => '-26.2971569330385',
  'Sample' => 'sc_41.P0',
  'Cd48' => '-3.9074064600961',
  'control.2' => '0',
  'Runx1' => '-26.2971569330385',
  'Procr' => '-26.2971569330385',
  'Ccnf1' => '-6.5548285066252',
  'Gata1' => '-26.2971569330385',
  'Byglycan' => '-26.2971569330385',
  'Ccng1' => '-26.2971569330385',
  'Flt3' => '-26.2971569330385',
  'Ccnd1' => '-26.2971569330385',
  'Cbx4' => '-26.2971569330385',
  'Tie1' => '-26.2971569330385',
  'Pbx1' => '-26.2971569330385',
  'Gata2' => '-26.2971569330385',
  'control.1' => '-1.67061075063',
  'Bmi1' => '-26.2971569330385',
  'p21' => '-26.2971569330385',
  'S100a6' => '-26.2971569330385',
  'Ccne1' => '-26.2875314820274'
};
is_deeply($data_table->get_line_asHash(0) , $exp , 'line 1');
#print "\$exp = ".root->print_perl_var_def($data_table->get_line_asHash(20) ).";\n";
$exp = {
  'Mpo' => '-4.9802797826442',
  'Rbl1' => '-5.5091147038424',
  'Pbx1' => '-4.5918883443965',
  'Bmi1' => '-26.8142012152357',
  'Cd150' => '-3.061570006832',
  'Ccnd1' => '-6.7302046880177',
  'Cited2' => '-3.5834025315174',
  'Ccna2' => '-4.6666603638661',
  'Tal1' => '-26.8142012152357',
  'control.1' => '-1.5768852217351',
  'Ccnb2' => '-26.8142012152357',
  'Ccng1' => '-5.404933974393',
  'S100a6' => '-26.8142012152357',
  'Gfi1' => '-26.8142012152357',
  'Flt3' => '-26.8142012152357',
  'Runx1' => '-26.8142012152357',
  'p21' => '-26.8142012152357',
  'Sample' => 'sc_10.P0',
  'Byglycan' => '-26.8142012152357',
  'Cd48' => '-2.2437985832465',
  'Esam1' => '-26.8142012152357',
  'control.2' => '-1.5904417062392',
  'Rbl2' => '-26.8142012152357',
  'p27' => '-6.0998631707883',
  'Cbx4' => '-26.8142012152357',
  'Procr' => '-26.8142012152357',
  'Ccnf1' => '-3.2090811147298',
  'ki67' => '-3.869381096177',
  'Cd34' => '-4.2293274064342',
  'Epor' => '-26.8142012152357',
  'Ikzf1' => '-26.8142012152357',
  'Hoxa5' => '-26.8142012152357',
  'p16' => '-26.8142012152357',
  'Gata2' => '-8.364872978105',
  'p19' => '-26.3445655760643',
  'Mpl' => '-3.9166034776698',
  'control' => '0',
  'Ccne1' => '-12.9590122370522',
  'Tie1' => '-26.8142012152357',
  'Gata1' => '-26.8142012152357'
};
is_deeply($data_table->get_line_asHash(20) , $exp , 'line 20');
#print $data_table ->AsTestString();

## now lets try to plo some data!!

my ( $xaxis, $yaxis ) = $data_table->plotXY($plugin_path.'/data/Output/Control_Control_1.png', 'control', 'control.1', $stefans_libs_GeneGroups );

##new axis function!
print "X min pixel: ".$xaxis->resolveValue($xaxis->min_value())."\n";
print "X corresponds to min value ".$xaxis->min_value()."\n";
print "X max pixel: ".$xaxis->resolveValue($xaxis->max_value())."\n";
print "X corresponds to max value ".$xaxis->max_value()."\n";

print "Y min pixel: ".$yaxis->resolveValue($yaxis->min_value())."\n";
print "Y corresponds to min value ".$yaxis->min_value()."\n";
print "Y max pixel: ".$yaxis->resolveValue($yaxis->max_value())."\n";
print "Y corresponds to max value ".$yaxis->max_value()."\n";

@values = ( -1,$xaxis->resolveValue(-1), $xaxis->pix2value($xaxis->resolveValue(-1)) );
ok( $values[0] == $values[2], "pix2value ($values[0] == $values[2]; $values[1])");

## Adding more groups to the object:

$exp= "GeneGrouping 0.1
markers	ref	ref.1
extends	nothing
Gr1	-12	-5	-20	-12
Gr2	-12	-6	-5	0";

($value) = $stefans_libs_GeneGroups->__Sets_in_order();
ok ($value -> match_2_group( -10, -14, 1 ), 'first value test G1' ) ;
ok ( ! $value -> match_2_group( -15, -14, 1 ), 'second value test G1' ) ;
ok ( ! $value -> match_2_group( -10, -1, 1 ), 'third value test G1' ) ;
ok ( $value -> match_2_group( -10, -1, 2 ), 'third value test G2' ) ;

my $test_table = stefans_libs::GeneGroups::R_table->new();
$test_table ->Add_2_Header( [ 'Samples', 'control', 'control.1' ] );
$test_table ->{'data'} = [[ 'C', -10, -1 ], ['B', -10,-14], ['A', -15,-14 ]  ];

@values =  $stefans_libs_GeneGroups->splice_expression_table( $test_table );

is_deeply([ map{ ref($_) } @values ], ['stefans_libs::GeneGroups::R_table', 'stefans_libs::GeneGroups::R_table', 'stefans_libs::GeneGroups::R_table' ],'got the re-ordered result objects' );
is_deeply([ map{scalar( @{$_->{'data'}} ) } @values ], [1,1,1 ],'re-ordered right numbers' );

print "\$exp = ".root->print_perl_var_def( \@values).";\n";

is_deeply([map{@{$_->{'data'}}} @values ], [ ['A', -15,-14 ],['B', -10,-14], [ 'C', -10, -1 ] ],'re-ordered right order' );


$test_table -> plotXY ($plugin_path.'/data/Output/control_control_1.png', 'control', 'control.1', $stefans_libs_GeneGroups );
#print "\$exp = ".root->print_perl_var_def($value ).";\n";

@values = ($xaxis->pix2value(550), $xaxis->pix2value(700), $yaxis->pix2value(380),$yaxis->pix2value(500));

print join(" ", @values );

ok ($stefans_libs_GeneGroups->AddGroup('control', 'control.1', $xaxis->pix2value(550), $xaxis->pix2value(700), $yaxis->pix2value(500),$yaxis->pix2value(400) ) == 3, 'Add first group (once more)' );
ok ($stefans_libs_GeneGroups->AddGroup('control', 'control.1', -1, 0, -4, 0 ) == 4, 'Add second group (once more)' );

print $stefans_libs_GeneGroups->AsString();
( $xaxis, $yaxis ) = $data_table->plotXY($plugin_path.'/data/Output/Control_Control_1.png', 'control', 'control.1', $stefans_libs_GeneGroups );
