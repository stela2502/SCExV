use strict;
use warnings;

#use lib "plugin_pathlib/";
use HTpcrA;

my $app = HTpcrA->apply_default_middlewares(HTpcrA->psgi_app);
$app;

