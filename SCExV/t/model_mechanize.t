use strict;
use warnings;
use Test::More;
use stefans_libs::root;

BEGIN { use_ok 'HTpcrA::Model::mech' }
use FindBin;
my $plugin_path = "$FindBin::Bin";


my $obj = HTpcrA::Model::mech->new();

ok(
	ref($obj) eq 'HTpcrA::Model::mech',
	'object eq HTpcrA::Model::mech'
);

my ( $variable, @variables, $exp, $c, $file, $md5_sum, $returnpage );
$c = test::c -> new();
$file = $plugin_path."/data/RandomForestResult.tar.gz";
$md5_sum = 'EhwEA/OfrYFriNfw7JN4ig'; ##will faile
$returnpage = "/randomforest/index/";

$obj -> post_randomForest (  $c, $file, $md5_sum, $returnpage );
done_testing();




package upload;
use strict;
use warnings;

sub new {
	my ( $name, $filename ) = @_;
	my $self = {'filename' => $filename };
	bless $self, $name;
	return $self;
}

sub copy_to {
	my ( $self, $to ) = @_;
	return system ( "cp $self->{'filename'} $to" );
}


package test::c;
use strict;
use warnings;

use FindBin;

sub new {
	my $self = {
		'config' => {
			'ncore'      => 4,
			'calcserver' => {
				'ncore'   => 32,
				'ip'      => '127.0.0.1:3000',
				'subpage' => "/fluidigm/index/"
			}
		  }

	};
	bless $self, shift;
	return $self;
}

sub session_path {
	my $p = "$FindBin::Bin" . "/data/Output/randomForestTest/";
	unless ( -d $p ) {
		mkdir($p);
		mkdir( $p . 'libs' );
	}
	system( "touch $p" . 'libs/Tool_RandomForest.R' );
	system( "touch $p" . 'libs/Tool_grouping.R' );
	system( "touch $p" . "norm_data.RData" );

	return $p;
}

sub config {    ## Catalyst function
	return shift->{'config'};
}

sub model {     ## Catalyst function
	my ( $self, $name ) = @_;
	return sender->new();

}

sub get_session_id {    ## Catalyst function
	return 1234556778;
}