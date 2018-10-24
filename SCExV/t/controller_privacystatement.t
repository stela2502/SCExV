use strict;
use warnings;
use Test::More;


use Catalyst::Test 'HTpcrA';
use HTpcrA::Controller::privacystatement;

ok( request('/privacystatement')->is_success, 'Request should succeed' );
done_testing();
