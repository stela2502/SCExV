#! /usr/bin/perl
use strict;
use warnings;
use Test::More tests => 7;
use PDL;

use FindBin;
my $plugin_path = "$FindBin::Bin";

BEGIN { use_ok 'stefans_libs::flexible_data_structures::data_table' }

my ( $value, @values, $exp, $data_table, $data_table2 );

$data_table = data_table->new();

$data_table->read_file($plugin_path."/data/Sample_Colors.xls" );

print $data_table->AsString();


#print "\$exp = ".root->print_perl_var_def($value ).";\n";
