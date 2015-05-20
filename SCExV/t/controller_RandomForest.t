use strict;
use warnings;
use Test::More;


use Catalyst::Test 'HTpcrA';
use HTpcrA::Controller::RandomForest;

ok( request('/randomforest')->is_success, 'Request should succeed' );
done_testing();
