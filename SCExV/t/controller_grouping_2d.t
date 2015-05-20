use strict;
use warnings;
use Test::More;


use Catalyst::Test 'HTpcrA';
use HTpcrA::Controller::grouping_2d;

ok( request('/grouping_2d')->is_success, 'Request should succeed' );
done_testing();
