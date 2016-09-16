use strict;
use warnings;
use Test::More;


use Catalyst::Test 'HTpcrA';
use HTpcrA::Controller::complex_grouping;

ok( request('/complex_grouping')->is_success, 'Request should succeed' );
done_testing();
