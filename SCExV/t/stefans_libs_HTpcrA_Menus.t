#! /usr/bin/perl
use strict;
use warnings;
use Test::More tests => 2;
BEGIN { use_ok 'stefans_libs::HTpcrA::Menue' }

my ( $value, @values, $exp );
my $obj = stefans_libs::HTpcrA::Menue -> new();
is_deeply ( ref($obj) , 'stefans_libs::HTpcrA::Menue', 'simple test of function stefans_libs::HTpcrA::Menus -> new()' );

#print "\$exp = ".root->print_perl_var_def($value ).";\n";


