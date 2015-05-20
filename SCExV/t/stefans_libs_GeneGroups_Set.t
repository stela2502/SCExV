#! /usr/bin/perl
use strict;
use warnings;
use Test::More tests => 2;
BEGIN { use_ok 'stefans_libs::GeneGroups::Set' }

my ( $value, @values, $exp );
my $stefans_libs_GeneGroups_Set = stefans_libs::GeneGroups::Set -> new();
is_deeply ( ref($stefans_libs_GeneGroups_Set) , 'stefans_libs::GeneGroups::Set', 'simple test of function stefans_libs::GeneGroups::Set -> new()' );

#print "\$exp = ".root->print_perl_var_def($value ).";\n";


