package HTpcrA::Controller::RandomForest;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }
with 'HTpcrA::EnableFiles';
use Digest::MD5;
=head1 NAME

HTpcrA::Controller::RandomForest - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index : Local : Form  {
    my ( $self, $c, @args ) = @_;
    Carp::confess ('broken as not updated lately! incompatible with the S4 object');
    # all I need to do here is this:
    #  data <- rfCluster(data, rep = 1, SGE = F, email='none@nowhere.de', k = 12, slice = 2 )
    # wait long enough (e.g. 15 min)
    #  data <- rfCluster(data, rep = 1, SGE = F, email='none@nowhere.de', k = 12, slice = 2 )
    # reanalyze with grouping 'RFgrouping RFclust 1'
    
	$self->{'form_array'} = [];
	$c->form->method('post');
	$c->form->field(
			'comment'  => 'session',
			'name'     => 'session',
			'type' => 'text',
			'required' => 1,
	);
	$c->form->field(
			'comment'  => 'file',
			'name'     => 'fn',
			'type' => 'file',
			'required' => 1,
	);
	$c->form->field(
			'comment'  => 'md5',
			'name'     => 'md5',
			'type' => 'text',
			'required' => 1,
	);
	if ( $c->form->submitted && $c->form->validate ) {
		#warn root::get_hashEntries_as_string($c->req->uploads() , 3, "Uploads") ;
		my $upload  = $c->req->uploads()->{'fn'};# $c->form->field('fn') ;
		my $ctx = Digest::MD5->new;
		$ctx->addfile($upload->fh());
		my $md5_sum = $ctx->b64digest;
		unless ( $md5_sum eq $c->form->field('md5') ) {
			## this file is not the right file!
			$c->response->body('Sorry, but this file has not the right md5 sum!('. $md5_sum.")\n" );
			$c->model('scrapbook')->init( $c->scrapbook() )->Add('Sorry, but this file has not the right md5 sum!('. $md5_sum.")\n");
			$c->detach();
		}
		my $res  = $c->model('RandomForest') -> recieve_RandomForest( $c, $upload, $c->form->field('session') );
		unless ( $res ){
			## Oh too late - this session has expired!
			$c->response->body('Sorry, but this session has expired!'. $c->form->field('session') ."\n" );
			$c->detach();
		}
		$c->response->body("Done!\n" );
		$c->detach();
	}
	$c->stash->{'template'} = 'message.tt2';
}

sub calculate : Local : Form {
	my ( $self, $c, @args ) = @_;
	$self->check($c,'upload');
	$self->{'form_array'} = [];
	$c->form->field(
			'comment'  => 'total tree count (more is better and slower)',
			'name'     => 'Numer of Trees',
			'type' => 'text',
			'value' => 500,
			'required' => 1,
	);
	$c->form->field(
			'comment'  => 'total amount of random forest calculations (more is better and slower)',
			'name'     => 'Numer of Forests',
			'type' => 'text',
			'value' => 500,
			'required' => 1,
	);
	$c->form->field(
			'comment'  => 'number of Gene Groups',
			'name'     => 'k',
			'type' => 'text',
			'value' => 10,
			'required' => 1,
	);
	$c->form->field(
			'comment'  => 'total subset of cells (max total -20)',
			'name'     => 'Number of Used Cells',
			'value' => '200',
			'required' => 1,
	);
	foreach ( @{ $self->{'form_array'} } ) {
		$c->form->field( %{$_} );
	}
	if ( $c->form->submitted && $c->form->validate ) {
		my $dataset = $self->__process_returned_form( $c );
		
		$c->model('scrapbook')->init( $c->scrapbook() )
	  ->Add("<h3>Local RFcluster run will be started</h3>\n<p>Time of finish: "
		  . $self->NOW()
		  . "</p><i>options:"
		  . $self->options_to_HTML_table($dataset)
		  . "</i>\n" );
		  

		
		$c->model('RandomForest') -> RandomForest ($c,  $dataset , 1); ## takes care of deployment (local/server)
		$c->res->redirect( $c->uri_for("/analyse/index/") );
		$c->detach();
	}
	$c->stash->{'template'} = 'message.tt2';
}

sub newgrouping : Local : Form {
	my ( $self, $c, @args ) = @_;
	my $path = $self->check($c,'upload');	
	my $grps = { map {$_ => 1} $c->all_groupings() };
	unless ( $grps->{'Rscexv_RFclust_1'} ) {
		$c->stash->{'ERROR'} = "Sorry you first need to create the random forest grouping once to use this function.";
	}
	$self->{'form_array'} = [];

	
	$c->form->field(
			'comment'  => 'number of Gene Groups',
			'name'     => 'k',
			'type' => 'text',
			'value' => 10,
			'required' => 1,
	);
	$c->form->field(
			'comment'  => 'the new group name',
			'name'     => 'Group Name',
			'value' => 'random forest regroup 1',
			'required' => 1,
	);
	foreach ( @{ $self->{'form_array'} } ) {
		$c->form->field( %{$_} );
	}
	if ( $c->form->submitted && $c->form->validate ) {
		unless ( $grps->{'Rscexv_RFclust_1'} ) {
			$c->res->redirect( $c->uri_for("/analyse/index/" )) ;
			$c->detach();
		}
		my $dataset = $self->__process_returned_form( $c );
		my $analysis_conf = $self->config_file( $c, 'rscript.Configs.txt' );
		
		$c->model('scrapbook')->init( $c->scrapbook() )
	  ->Add("<h3>RandomForest calculation</h3>\n<p>I send the data to the calculation server!</p><i>"
		  . $self->options_to_HTML_table($dataset)
		  . "</i>\n" );
		my $script =
		  $c->model('RScript')->create_script( $c, 'recluster_RF_data', $dataset );
		$c->model('RScript')
		  ->runScript( $c, $path, 'recluster_RF_data.R', $script, 'wait' );
		  
		$c->res->redirect( $c->uri_for("/analyse/re_run/".$dataset->{'Group Name'}."/$analysis_conf->{'GeneUG'}/") );
		$c->detach();
	}
	$c->stash->{'template'} = 'message.tt2';
}

=head1 AUTHOR

Stefan Lang

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
