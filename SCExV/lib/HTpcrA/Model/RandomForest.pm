package HTpcrA::Model::RandomForest;
use Moose;
use namespace::autoclean;
use POSIX;

extends 'Catalyst::Model';

use Digest::MD5;

=head1 NAME

HTpcrA::Model::RandomForest - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 AUTHOR

Stefan Lang

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.


=head2 RandomForest

This tool will make sure, that the random forest is created.
It will also create a RandomForest script calculating the thing.
If the RandomForest is created calling this function will create 
a user group named RandomForest_n5 (e.g. 5 groups)
These groups will be created whenever the calculation is finished.

This tool will also evaluate some config variables to see whether 
there is a calculation server attached to this server.

$config->{'calcserver' => {
	'to' => 'http://123.123.123.123/cgi-bin/foresthelper/reciever.cgi',
	'ncore' => 32,
}}

=cut

#sub new {
#	my ( $app, @arguments ) = @_;
#	return HTpcrA::Model::RandomForest->new();
#}

sub RandomForest {
	my ( $self, $c, $dataset, $redo ) = @_;
	my $path = $c->session_path();
	$dataset->{'procs'} ||= $c->config->{'ncore'};
	$dataset->{'geneGroups'} ||= 10;
	$dataset->{'procs'} = $c->config->{'calcserver'}->{'ncore'}
	  if ( defined $c->config->{'calcserver'} );
	$dataset->{'cluster_on'} ||= 'Expression';
	my ( @files, @gene_files );

	chdir($path);
	if ($redo) {
		if ( -f $path . "randomForest1.R" ) {
			mkdir ( $path.'old_groupings');
			system( 'mv ' . $path . "randomForest* old_groupings" );
			system( 'mv ' . $path . "Random* old_groupings" );
		}
	}
	open( OUT, ">" . $path . "RandomForest_groupings.txt" );
	print OUT join( "\n", 2, 4, 6, 8, 10, 12, 14, 16, 18, 20 );
	close(OUT);
	unless ( -f $path . "randomForest1.R" ) {
		## create the script and run it!
		## the script has to read in a list of wanted grouings at the end that can be modified while runing the script.
		## the forest will be saved to disk and if present I will create the grouping right here.
		## added new multiprocessor option to calculate the random forests $dataset->procs
		my ( $scripts, @files ) = $self->_random_forest_script(
			$dataset->{'procs'}, $path,
			$dataset->{'target_trees'},
			$dataset->{'cluster_on'}
		);
		@gene_files = @{ $files[1] };
		@files      = @{ $files[0] };
		my $i = 1;
		foreach my $script (@$scripts) {
			open( RSCRIPT, ">$path/randomForest$i.R" )
			  or Carp::confess(
				"I could not create the R script '$path/randomForest$i.R'\n$!\n"
			  );
			print RSCRIPT $script;
			close(RSCRIPT);
			$i++;
		}

		if ( defined $c->config->{'calcserver'} ) {
			## here I need to pack the R script + datasets
			open( OUT, ">$path/RandomForestStarter.sh" ) or die "$!\n";
			print OUT join(
				"",
				map {
					    "R CMD BATCH  --no-save --no-restore --no-readline -- "
					  . $_ . " &\n"
				  } map { my $f = $_; $f =~ s/data$//; $f } @files,
				"randomForest1.R",
				"randomForest2.R"
			);
			close(OUT);
			chdir($path);
			system(
				"tar -cf RandomForest_transfer.tar "
				  . join( " ",
					'RandomForestStarter.sh',
					map { my $f = $_; $f =~ s/data$//; $f } @files,
					"randomForest1.R",
					"randomForest2.R",
					'libs/Tool_grouping.R',
					'libs/Tool_RandomForest.R',
					'norm_data.RData' )
			);
			system('gzip -9 RandomForest_transfer.tar');

			## and send this information to the recieving web page

			my $file = [
				$path
				  . '/RandomForest_transfer.tar.gz'
				,    # The file you'd like to upload.
				'RandomForest_transfer.tar.gz'
				,    # The filename you'd like to give the web server.
				'Content-type' =>
				  'application/x-tar' # Any other flags you'd like to add go here.
			];
			my $md5_sum = $self->file2md5str( @$file[0] );
			my @return = split( "/", $c->uri_for('/randomforest/index/') );
			## I need to get rid of the http:// part and the optional :3000
			@return = @return[ 3 .. @return - 1 ];
			$c->model('mech')
			  ->post_randomForest( $c, @$file[0], $md5_sum,
				join( "/", @return ) );
		}
		elsif ( ! $dataset->{'not_calculate'} ) {
			foreach my $f (@files) {
				$f =~ s/data$//;
				system(
'/bin/bash -c "DISPLAY=:7 R CMD BATCH --no-save --no-restore --no-readline -- '
					  . $f
					  . ' > R.run.log &"' );
			}
			for ( $i = 1 ; $i <= @$scripts ; $i++ ) {
				system(
'/bin/bash -c "DISPLAY=:7 R CMD BATCH --no-save --no-restore --no-readline -- '
					  . "randomForest$i.R"
					  . ' > R.run.log &"' );
			}
		}

		$scripts =
		    "##read the existing randomForest dataset or die!\n"
		  . "source ('libs/Tool_RandomForest.R')\n"
		  . "source ('libs/Tool_grouping.R')\n"
		  . "load('RandomForestdistRFobject.RData')\n"
		  . "load('norm_data.RData')\n"
		  ;    ## this will fail if the main script has not finished!
		## calculate the groupings
		## get the groupings that should be defined!
		$scripts .=
"createGroups_randomForest( data.filtered, fname='RandomForest_groupings.txt')\n"
		  . "load('RandomForestdistRFobject_genes.RData')\n"
		  . "createGeneGroups_randomForest (  data.filtered, $dataset->{'geneGroups'} )\n";
		open( RSCRIPT, ">$path/RandomForest_create_groupings.R" )
		  or Carp::confess(
"I could not create the R script '$path/RandomForest_create_groupings.R'\n$!\n"
		  );
		print RSCRIPT $scripts . "release_lock (lock.name)\n";
		close(RSCRIPT);
	}
	unless ( -f $path . "RandomForestdistRFobject.RData" ) {
		system(
'/bin/bash -c "DISPLAY=:7 R CMD BATCH --no-save --no-restore --no-readline -- randomForest.R > R.run.log &"'
		);
	}
	system( "touch $path" . "RandomForest_groupings.txt" );
	system( "echo $dataset->{'cluster_amount'} >> $path"
		  . "RandomForest_groupings.txt" );
	chdir($path);
	system(
'/bin/bash -c "DISPLAY=:7 R CMD BATCH --no-save --no-restore --no-readline -- RandomForest_create_groupings.R > R.run.log"'
	);
	return 1;
}

sub file2md5str {
	my ( $self, $filename ) = @_;
	my $md5_sum = 0;
	if ( -f $filename ) {
		open( FILE, "<$filename" );
		binmode FILE;
		my $ctx = Digest::MD5->new;
		$ctx->addfile(*FILE);
		$md5_sum = $ctx->b64digest;
		close(FILE);
	}
	return $md5_sum;
}

sub _random_forest_script {
	my ( $self, $procs, $path, $target_trees, $cluster_on ) = @_;
	my ( $forests, $trees, @files, @gene_files );
	$target_trees ||= 6e+6;
	$trees = int( ( $target_trees / $procs )**0.5 );
	$forests = int( $trees / 60 );

	my $script =
	    "## this is using work published in\n"
	  . "## Tao Shi and Steve Horvath (2006) Unsupervised Learning with Random Forest Predictors. \n"
	  . "## Journal of Computational and Graphical Statistics. Volume 15, Number 1, March 2006, pp. 118-138(21)\n"
	  . "initial.options <- commandArgs(trailingOnly = FALSE)\n"
	  . "script.dir <- dirname ( initial.options[ grep( 'randomForest', initial.options ) ] )\n"
	  . "print ( paste( 'working directory = ',script.dir))\n"
	  . "setwd(script.dir)\n"
	  . "lock.name <- 'randomForest_worker_NUMBER.Rdata'\n"
	  . "lock.name2 <- 'randomForest_worker_genes_NUMBER.Rdata'\n"
	  . "source ('libs/Tool_RandomForest.R')\n"
	  . "source ('libs/Tool_grouping.R')\n"
	  . "if ( ! identical( lock.name, paste('randomForest_worker_NUM','BER.Rdata', sep='') ) ) {\n"
	  . "  set_lock( lock.name )\n"
	  . "  set_lock( lock.name2 )\n" . "}\n"
	  . "load ('norm_data.RData')\n"
	  . "no.forests=$forests\n"
	  . "no.trees=$trees\n";
	if ( $cluster_on eq "both" ) {
		$script .=
"datRF <- data.frame(cbind( data.filtered\$z\$PCR, data.filtered\$FACS ))\n";
	}
	elsif ( $cluster_on eq "FACS" ) {
		$script .= "datRF <- data.frame(data.filtered\$FACS )\n";
	}
	else {
		$script .= "datRF <- data.frame(data.filtered\$z\$PCR )\n";
	}

	## calculate the forests
	for ( my $i = 0 ; $i < $procs ; $i++ ) {
		open( RSCRIPT, ">$path/randomForest_worker_" . $i . ".R" )
		  or Carp::confess(
			    "I could not create the R script '$path/randomForest_worker_"
			  . $i
			  . ".R'\n$!\n" );
		my $tmp = $script;

		$tmp =~ s/_NUMBER/_$i/g;
		print RSCRIPT $tmp

		  . "system.time (RF <- calculate_RF(  datRF, $forests , $trees ,imp=T, oob.prox1=T, mtry1=3 ))\n"
		  . "save_RF(RF, 'randomForest_worker_"
		  . $i
		  . ".Rdata' )\n"
		  ## The gene based randomForests
		  . "datRF <- data.frame(t(cbind( data.filtered\$z\$PCR, data.filtered\$FACS )))\n"
		  . "attach(datRF)\n"
		  . "system.time (RF <- calculate_RF( datRF, $forests , $trees ,imp=T, oob.prox1=T, mtry1=3 ))\n"
		  . "save_RF(RF, 'randomForest_worker_genes_"
		  . $i
		  . ".Rdata' )\n"
		  . "if ( ! identical( lock.name, paste('randomForest_worker_NUM','BER.Rdata', sep='') ) ) {\n"
		  . "   release_lock (lock.name)\n"
		  . "   release_lock (lock.name2)\n" . "}\n";
		close(RSCRIPT);
		$files[$i]      = "randomForest_worker_" . $i . ".Rdata";
		$gene_files[$i] = "randomForest_worker_genes_" . $i . ".Rdata";
	}
	## calculate the distance matrix
	my $script2 =
	    $script
	  . "datRF <- data.frame(t(cbind( data.filtered\$z\$PCR, data.filtered\$FACS )))\n"
	  . "attach(datRF)\n"
	  . "Rf.data <- read_RF ( c('"
	  . join( "', '", @gene_files ) . "'),"
	  . scalar(@gene_files) . "  )\n"
	  . "distRF = RFdist(Rf.data, datRF, no.tree= $trees, imp=F)\n"
	  . "save( distRF, file=\"RandomForestdistRFobject_genes.RData\" )\n";

	$script .=
"datRF <- data.frame(cbind( data.filtered\$z\$PCR, data.filtered\$FACS ))\n"
	  . "attach(datRF)\n"
	  . "Rf.data <- read_RF ( c('"
	  . join( "',\n '", @files ) . "'),"
	  . 25
	  . " )\n"    ## 25*20 sec wait for finish of the worker scripts
	  . "distRF = RFdist(Rf.data, datRF, no.tree= $trees, imp=F)\n"
	  . "save( distRF, file=\"RandomForestdistRFobject.RData\" )\n"
	  ## gene based random forest
	  . "system ( '/bin/bash -c \"DISPLAY=:7 R CMD BATCH --no-save --no-restore --no-readline -- RandomForest_create_groupings.R > R.run.log &\"')\n";
	return ( [ $script, $script2 ], \@files, \@gene_files );
}

sub recieve_RandomForest {
	my ( $self, $c, $upload, $session_id ) = @_;
	my $path = $c->session_path($session_id);
	return undef unless ( -d $path );    ## session has ended!
	chdir($path);
	$c->model('scrapbook')->init( $path."/Scrapbook/Scrapbook.html" )
	  ->Add("<h3>RandomForest calculation</h3>\n<p>I recieved the data from the calculation server!</p>\n" );
	mkdir('old_groupings') unless ( -d 'old_groupings');
	if ( -f 'RandomForest_transfereBack.tar.gz' ) {
		system("mv RandomForest* old_groupings");
		system("mv forest_* old_groupings");
		system("mv Grouping.randomForest* old_groupings");
		system("cp old_groupings/RandomForest_create_groupings.R ./");
		system ( 'cp old_groupings/RandomForest_groupings.txt ./');
		#cd .././c	Carp::confess ( "cp old_groupings/RandomForest_create_groupings.R ./\nin path $path");
	}
	$upload->copy_to( $path . 'RandomForest_transfereBack.tar.gz' );
	system('tar -zxf RandomForest_transfereBack.tar.gz');
	system(
'/bin/bash -c "DISPLAY=:7 R CMD BATCH --no-save --no-restore --no-readline -- RandomForest_create_groupings.R > R.run.log &\"'
	);
	return 1;
}

__PACKAGE__->meta->make_immutable;

1;
