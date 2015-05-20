use strict;
use warnings;
use Test::More;


use Catalyst::Test 'HTpcrA';
use HTpcrA::Controller::test;

ok( request('/test')->is_success, 'Request should succeed' );
done_testing();
