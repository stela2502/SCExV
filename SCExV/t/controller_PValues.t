use strict;
use warnings;
use Test::More 'no_plan';

use Test::WWW::Mechanize::Catalyst "HTpcrA";
use stefans_libs::flexible_data_structures::data_table;

my $mech              = Test::WWW::Mechanize::Catalyst->new;

$mech->get_ok("http://localhost/");
$mech->get_ok("http://localhost/files/use_example_data/");
$mech->get_ok("http://localhost/analyse/run_first/");

$mech->get_ok('http://localhost/pvalues');
$mech->form_number(1);
$mech->click_button( value => 'Submit' );
$mech->content_contains(  'onClick=\'updateimage("mygallery", "pictures"', "P value results are loaded");

$mech->get_ok("http://localhost/scrapbook/index/");
$mech->content_contains('>download the stat results</a>');
$mech->content_lacks("<a href='TABLE_FILE'");

#done_testing( );
