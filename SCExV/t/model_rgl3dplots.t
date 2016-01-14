use strict;
use warnings;
use Test::More;


BEGIN { use_ok 'HTpcrA::Model::rgl3dplots' }

my $obj = HTpcrA::Model::rgl3dplots->new();
my $c = test::c->new();
my $variable = $c->session_path();
ok ( -d $variable, 'session path created' );

$obj -> updateRGLjs ( $c );

foreach ( 'htmlwidgets.js', 'rgl.css', 'rglClass.src.js', 'CanvasMatrix.src.js', 'rglWebGL.js' ) {
	if ( $_ =~ m/js$/ ){
		ok ( -f $c->session_path().'../../scripts/'.$_, "javascript file $_ copied" );
	}
	else {
		ok ( -f $c->session_path().'../../css/'.$_, "css file $_ copied" );
	}
}

done_testing();




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
	my $p = "$FindBin::Bin" . "/data/Output/root/tmp/someNumber/";
	# my $p = "$FindBin::Bin" . "/../root/";
	system( "mkdir -p $p" ) unless ( -d $p );
	mkdir ( "$p../../css" ) unless ( -d "$p../../css");
	mkdir ( "$p../../scripts" ) unless ( -d "$p../../scripts");
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