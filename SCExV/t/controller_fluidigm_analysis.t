use strict;
use warnings;
use Test::More;

use Test::WWW::Mechanize::Catalyst;
use HTpcrA;
use Catalyst::Test 'HTpcrA';
use HTpcrA::Controller::analyse;
use HTpcrA::Controller::Files;
use HTpcrA::EnableFiles;

use FindBin;
my $plugin_path = "$FindBin::Bin";

ok( request('/files/upload/')->is_success, 'Request should succeed' ); ## I first need to upload data...

my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'HTpcrA');
$mech->get_ok( '/files/upload/' );
    
# I need to upload some files!!

$mech->submit_form_ok( {
            form_number => 1,
            fields      => {
                PCRTable => "$plugin_path/data/source_data/113129216_y112_P-F.csv",
                facsTable => '',
                normalize2 => 'none',
                rmGenes => 'Yes',
                userGroup => 'an integer list of group ids in the same order as the table(s)',
                maxGenes => 'any',
                maxCT => 25,
                nullCT => 40,
                'Negative control genes' => '',
                
            },
        }, 'try to upload a file'
    );

$mech->get_ok( '/files/upload/' );
$mech->content_contains("113129216_y112_P-F.csv", "File uploaded!");

ok( request('/analyse/index')->is_success, 'File uploaded' ); ## I first need to upload data...


#print request('/files/upload/')->content();
done_testing();
