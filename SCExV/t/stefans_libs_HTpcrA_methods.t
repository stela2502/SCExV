#! /usr/bin/perl
use strict;
use warnings;
use Test::More tests => 2;
BEGIN { use_ok 'stefans_libs::HTpcrA::methods' }

my ( $value, @values, $exp );
my $stefans_libs_HTpcrA_methods = stefans_libs::HTpcrA::methods -> new();
is_deeply ( ref($stefans_libs_HTpcrA_methods) , 'stefans_libs::HTpcrA::methods', 'simple test of function stefans_libs::HTpcrA::methods -> new()' );

#print "\$exp = ".root->print_perl_var_def($value ).";\n";


