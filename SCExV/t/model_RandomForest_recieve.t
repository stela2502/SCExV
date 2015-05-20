use strict;
use warnings;
use Test::More;
use stefans_libs::root;

BEGIN { use_ok 'HTpcrA::Model::RandomForest' }

use FindBin;
my $plugin_path = "$FindBin::Bin";
my $file = "$plugin_path/data/RandomForestResult.tar.gz";
die "Sorry the required input file is not accessable! ($file)\n" unless ( -f $file );
my $obj = HTpcrA::Model::RandomForest->new();

ok(
	ref($obj) eq 'HTpcrA::Model::RandomForest',
	'object eq HTpcrA::Model::RandomForest'
);

## this is kind of trivial. get the file and extract it on the server - run the R script that calculates the groupings.
my ( $variable, @variables, $exp );

my $path = test::c->session_path();
system("rm -R $path");
my $c = test::c->new();
$variable = $obj->recieve_RandomForest( $c , upload->new($file), 'randomForestTest' );

ok ( $variable, "No error in the upload function" );

foreach ( qw(RandomForestdistRFobject_genes.RData RandomForestdistRFobject.RData RandomForest_transfereBack.tar.gz) ) {
	ok (-f "$path/$_", "File $_ extracted from random forest archive" );
}

done_testing();

#print "\$exp = ".root->print_perl_var_def($value ).";\n";

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
				'ip'      => '127.0.0.1',
				'subpage' => "/weblog/fluidigm/"
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

1;

