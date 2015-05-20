use strict;
use warnings;
use Test::More;

use Test::WWW::Mechanize::Catalyst;


use Catalyst::Test 'HTpcrA';

my $mech =  Test::WWW::Mechanize::Catalyst ->new(catalyst_app => 'HTpcrA');

#$mech->get_ok('/' );
#$mech->get_ok('/files/upload/' );
$mech->get_ok('/help/index/files/upload/PCRTable/');

#print $mech->content();

$mech->content_contains( 'Here you can upload your RT-qPCR data using either tab separated tables' );

$mech->get_ok('/help/index/analyse/index/mds_alg/');

done_testing();
