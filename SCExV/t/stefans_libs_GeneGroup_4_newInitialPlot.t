#! /usr/bin/perl
use strict;
use warnings;
use Test::More tests => 12;
BEGIN { use_ok 'stefans_libs::GeneGroups' }

use FindBin;
my $plugin_path = "$FindBin::Bin";

my ( $value, @values, $exp );
my $gg = stefans_libs::GeneGroups->new();
is_deeply( ref($gg),
	'stefans_libs::GeneGroups',
	'simple test of function stefans_libs::GeneGroups -> new()' );
	
$gg->read_grouping( $plugin_path ."/data/ggplot4/Grouping.CD45.2.PE.Texas.Red.A.CD55.PE.A" );
$gg->read_data( $plugin_path ."/data/ggplot4/merged_data_Table.xls", my $use_data_table_obj = 1);
$gg->read_old_grouping( $plugin_path ."/data/ggplot4/2D_data_color.xls" );

##clean up
mkdir ( $plugin_path ."/data/ggplot4/Output/") unless ( -d $plugin_path ."/data/ggplot4/Output/");
unlink( $plugin_path ."/data/ggplot4/Output/CD45.2.PE.Texas.Red.A.CD55.PE.A.png" ) if ( -f $plugin_path ."/data/ggplot4/Output/CD45.2.PE.Texas.Red.A.CD55.PE.A.png" );

$gg->plot($plugin_path ."/data/ggplot4/Output/CD45.2.PE.Texas.Red.A.CD55.PE.A.png", "CD45.2.PE.Texas.Red.A", "CD55.PE.A" );
ok( -f $plugin_path ."/data/ggplot4/Output/CD45.2.PE.Texas.Red.A.CD55.PE.A.png", 'figure file created' );

$gg->clear();

$gg->read_data( $plugin_path ."/data/ggplot4/merged_data_Table.xls", $use_data_table_obj = 1);
$gg->read_old_grouping( $plugin_path ."/data/ggplot4/2D_data_color.xls" );
unlink( $plugin_path ."/data/ggplot4/Output/CD45.2.PE.Texas.Red.A.CD55.PE.A.oldG.png" ) if ( -f $plugin_path ."/data/ggplot4/Output/CD45.2.PE.Texas.Red.A.CD55.PE.A.oldG.png" );
$gg->plot($plugin_path ."/data/ggplot4/Output/CD45.2.PE.Texas.Red.A.CD55.PE.A.oldG.png", "CD45.2.PE.Texas.Red.A", "CD55.PE.A" );

