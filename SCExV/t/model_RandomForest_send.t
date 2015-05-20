use strict;
use warnings;
use Test::More;
use stefans_libs::root;

BEGIN { use_ok 'HTpcrA::Model::RandomForest' }

my $obj = HTpcrA::Model::RandomForest->new();

ok(
	ref($obj) eq 'HTpcrA::Model::RandomForest',
	'object eq HTpcrA::Model::RandomForest'
);

my ( $variable, @variables, $exp );



1;

