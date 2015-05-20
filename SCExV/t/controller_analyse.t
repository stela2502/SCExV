#! /usr/bin/perl -d:NYTProf
use strict;
use warnings;
use Test::More tests => 4;

use FindBin;
my $plugin_path = "$FindBin::Bin";


use Test::WWW::Mechanize::Catalyst;

use Catalyst::Test 'HTpcrA';

use HTpcrA::Controller::analyse;

my $mech =  Test::WWW::Mechanize::Catalyst ->new(catalyst_app => 'HTpcrA');

$mech->get_ok('/files/upload/');
$mech ->content_contains( '"formField"><input id="facsTable" name="facsTable" type="file"', 'file upload page' );
$mech ->content_contains( 'none</BR>', 'no data present' );

$mech->form_number(1);

$mech->field( 'facsTable' => $plugin_path."/data/PCR_dataset.csv" );
$mech->click('_submit');
print $mech->content();
$mech->content_contains( 'PCR_dataset.csv', 'data added' );


## lets upload a file






done_testing();

#print $mech->content();
