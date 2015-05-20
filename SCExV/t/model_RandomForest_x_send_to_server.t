use strict;
use warnings;
use Test::More;
use stefans_libs::root;

BEGIN { use_ok 'HTpcrA::Model::RandomForest' }

my $obj = HTpcrA::Model::RandomForest->new();

ok(
	ref($obj) eq 'HTpcrA::Model::RandomForest',
	'object eq HTpcrA::Model::RandomForest'
);

my ( $variable, @variables, $exp );

my $path = test::c->session_path();
system("rm -R $path");
$variable = $obj->RandomForest( test::c->new(),
	{ 'procs' => 4, 'cluster_amount' => 10, } );

if ( ok( -f $path . "RandomForestStarter.sh", 'RandomForestStarter.sh' ) ) {
	open( IN, "<" . $path . "RandomForestStarter.sh" );
	$exp = [
'R CMD BATCH  --no-save --no-restore --no-readline -- randomForest_worker_0.R &
',
'R CMD BATCH  --no-save --no-restore --no-readline -- randomForest_worker_1.R &
',
'R CMD BATCH  --no-save --no-restore --no-readline -- randomForest_worker_2.R &
',
'R CMD BATCH  --no-save --no-restore --no-readline -- randomForest_worker_3.R &
',
'R CMD BATCH  --no-save --no-restore --no-readline -- randomForest_worker_4.R &
',
'R CMD BATCH  --no-save --no-restore --no-readline -- randomForest_worker_5.R &
',
'R CMD BATCH  --no-save --no-restore --no-readline -- randomForest_worker_6.R &
',
'R CMD BATCH  --no-save --no-restore --no-readline -- randomForest_worker_7.R &
',
'R CMD BATCH  --no-save --no-restore --no-readline -- randomForest_worker_8.R &
',
'R CMD BATCH  --no-save --no-restore --no-readline -- randomForest_worker_9.R &
',
'R CMD BATCH  --no-save --no-restore --no-readline -- randomForest_worker_10.R &
',
'R CMD BATCH  --no-save --no-restore --no-readline -- randomForest_worker_11.R &
',
'R CMD BATCH  --no-save --no-restore --no-readline -- randomForest_worker_12.R &
',
'R CMD BATCH  --no-save --no-restore --no-readline -- randomForest_worker_13.R &
',
'R CMD BATCH  --no-save --no-restore --no-readline -- randomForest_worker_14.R &
',
'R CMD BATCH  --no-save --no-restore --no-readline -- randomForest_worker_15.R &
',
'R CMD BATCH  --no-save --no-restore --no-readline -- randomForest_worker_16.R &
',
'R CMD BATCH  --no-save --no-restore --no-readline -- randomForest_worker_17.R &
',
'R CMD BATCH  --no-save --no-restore --no-readline -- randomForest_worker_18.R &
',
'R CMD BATCH  --no-save --no-restore --no-readline -- randomForest_worker_19.R &
',
'R CMD BATCH  --no-save --no-restore --no-readline -- randomForest_worker_20.R &
',
'R CMD BATCH  --no-save --no-restore --no-readline -- randomForest_worker_21.R &
',
'R CMD BATCH  --no-save --no-restore --no-readline -- randomForest_worker_22.R &
',
'R CMD BATCH  --no-save --no-restore --no-readline -- randomForest_worker_23.R &
',
'R CMD BATCH  --no-save --no-restore --no-readline -- randomForest_worker_24.R &
',
'R CMD BATCH  --no-save --no-restore --no-readline -- randomForest_worker_25.R &
',
'R CMD BATCH  --no-save --no-restore --no-readline -- randomForest_worker_26.R &
',
'R CMD BATCH  --no-save --no-restore --no-readline -- randomForest_worker_27.R &
',
'R CMD BATCH  --no-save --no-restore --no-readline -- randomForest_worker_28.R &
',
'R CMD BATCH  --no-save --no-restore --no-readline -- randomForest_worker_29.R &
',
'R CMD BATCH  --no-save --no-restore --no-readline -- randomForest_worker_30.R &
',
'R CMD BATCH  --no-save --no-restore --no-readline -- randomForest_worker_31.R &
', 'R CMD BATCH  --no-save --no-restore --no-readline -- randomForest1.R &
', 'R CMD BATCH  --no-save --no-restore --no-readline -- randomForest2.R &
'
	];
	is_deeply( [<IN>], $exp, "right entries RandomForestStarter.sh" );
}

foreach ( 0 .. 31 ) {
	my $fn = "randomForest_worker_";
	ok( -f $path . "$fn$_.R", "$fn$_.R" );
	system("rm $fn$_.R");
}
foreach ( 1 .. 2 ) {
	my $fn = "randomForest";
	ok( -f $path . "$fn$_.R", "$fn$_.R" );
	system("rm $fn$_.R");
}

if (
	ok(
		-f $path . "RandomForest_transfer.tar.gz",
		'RandomForest_transfer.tar.gz'
	)
  )
{
	chdir($path);
	system("tar -zxf RandomForest_transfer.tar.gz");
	foreach ( 0 .. 31 ) {
		my $fn = "randomForest_worker_";
		ok( -f $path . "$fn$_.R", "untar $fn$_.R" );
		system("rm $fn$_.R");
	}
	foreach ( 1 .. 2 ) {
		my $fn = "randomForest";
		ok( -f $path . "$fn$_.R", "untar $fn$_.R" );
		system("rm $fn$_.R");
	}
}

done_testing();

#print "\$exp = ".root->print_perl_var_def($value ).";\n";

package test::c;
use strict;
use warnings;

use FindBin;
my $plugin_path = "$FindBin::Bin";

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
sub uri_for {
	my $str = shift;
	return "http://localhost/$str";
}
sub get_session_id {    ## Catalyst function
	return 1234556778;
}

package sender;
use strict;
use warnings;

sub new {
	my $self = {};
	bless $self, shift;
	return $self;
}

sub post_randomForest {
	my ( $self, $to, $what ) = @_;
	root::print_hashEntries( { 'to' => $to, 'what' => $what },
		4, "the call to mechanize->post:" );
}

1;

