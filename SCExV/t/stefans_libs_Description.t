#! /usr/bin/perl
use strict;
use warnings;
use Test::More tests => 5;
BEGIN { use_ok 'stefans_libs::Description' }

my ( $value, @values, $exp );
my $stefans_libs_Description = stefans_libs::Description -> new();
is_deeply ( ref($stefans_libs_Description) , 'stefans_libs::Description', 'simple test of function stefans_libs::Description -> new()' );

#print "\$exp = ".root->print_perl_var_def($value ).";\n";


sub or_set_to_default{
	my ( $self, $new, $default ) = @_;
	map { $new->{$_} ||= $default->{$_} } keys %$default, keys %$new ; 
	return $new;
}

$exp = { 'A' => 'a', 'B'=> 'b' };
$value = { 'A' => '1', 'B'=> '2'};

is_deeply ( or_set_to_default('nix', $value, $exp ), $value, 'A fully set hash does not get touched'  );
is_deeply ( or_set_to_default('nix', {}, $value ), $value, 'A ful hash for nothing at all'  );

is_deeply ( or_set_to_default('nix', $value, {} ), $value, 'A ful hash without a default.')