use strict;
use warnings;
use Test::More;


use Catalyst::Test 'HTpcrA';
use HTpcrA::Controller::GEOfiles;

ok( request('/geofiles')->is_success, 'Request should succeed' );
done_testing();
