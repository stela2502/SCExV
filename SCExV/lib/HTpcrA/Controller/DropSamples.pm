package HTpcrA::Controller::DropSamples;
use stefans_libs::flexible_data_structures::data_table;
use HTpcrA::EnableFiles;
use Moose;
use namespace::autoclean;

with 'HTpcrA::EnableFiles';

#BEGIN { extends 'HTpcrA::base_db_controler';};
BEGIN { extends 'Catalyst::Controller'; }
use Digest::MD5 qw(md5_hex);

=head1 NAME

HTpcrA::Controller::analyse - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

sub index : Path : Form {
	my ( $self, $c, @args ) = @_;
	#my $hash = $self->config_file( $c, 'dropping_samples.txt' );
	my $path = $self->check($c);
	
	$self->slurp_Heatmaps( $c, $path );
	
	if ( -f "$path/webGL/index.html" ) {
		$self->{'webGL'} = "$path/webGL/index.html";
		$self->slurp_webGL( $c, $self->{'webGL'}, $path );
		$c->stash->{'buttons'}         = $self->exclude_buttons($c);
	}

	## now the form to remove the samples
	$self->{'form_array'} = [];

	$self->Select_Options( $c, $path );

	push(
		@{ $self->{'form_array'} },
		{
			'comment'  => 'Sample Selection',
			'name'     => 'Samples',
			'value'    => '',
			'options'  => $self->{'select_options'},   ## any sample in the data
			'required' => 0,
			'multiple' => 1,
		}
	);
	push(
		@{ $self->{'form_array'} },
		{
			'comment'  => 'RegExp matching string',
			'name'     => 'RegExp',
			'value'    => '',
			'required' => 0,
		}
	);
	$self->Javascript($c);
	foreach ( @{ $self->{'form_array'} } ) {
		$c->form->field( %{$_} );
	}
	if ( $c->form->submitted && $c->form->validate ) {
		## exclude some samples!!
		$self->R_remove_samples( $c, $self->__process_returned_form($c) );
	}

	$c->form->template( $c->config->{'root'}.'src'. '/form/dropsamples.tt2' );
	$c->stash->{'template'} = 'DropSamples.tt2';
}

sub R_remove_samples {
	my ( $self, $c, $hash ) = @_;
	my $path = $c->session_path();

	my $script = $c->model('RScript')->create_script($c, 'remove_samples', $hash );
	$c->model('RScript')->runScript( $c, $path, 'DropSamples.R', $script, 1 );

	$c->model('scrapbook')->init( $c->scrapbook() )
	  ->Add("<h3>Drop Samples (Cells)</h3>\n<i>options:"
		  . $self->options_to_HTML_table($hash)
		  . "</i>\n" );
	$c->res->redirect( $c->uri_for("/analyse/re_run/") );
	$c->detach();
	return 1;

}

sub Select_Options {
	my ( $self, $c, $path ) = @_;
	my $data_table = data_table->new();
	$data_table->read_file( $path . "/Sample_Colors.xls" );
	$self->{'select_options'} = [
		map {
			{ $_ => $_ }
		} @{ $data_table->GetAsArray('SampleName') }
	];
	$self->{"Group_2_Sample"} =
	  $data_table->GetAsHashedArray( 'grouping', 'SampleName' );
	return $self->{'select_options'};
}

sub exclude_buttons {
	my ( $self, $c ) = @_;
	my $path = $c->session_path();
	
	my @colors = $self->colors_Hex( $c, $path);
	
	my $str = '';
	my $percent_width = int( 95 / @colors );
	
	for ( my $i = 0; $i < @colors; $i ++ ){
		$str .="<button style=\"width:$percent_width\%;height:70;background-color:". $colors[$i]. "\" onClick=\"window.location='"
		  . $c->uri_for("/dropsamples/drop_group/".($i+1) ). "'\"><b>Group $i</b></button>\n";
	}	
	return $str;
}

sub drop_group : Local {
	my ( $self, $c, $group_id ) = @_;
	$self->Select_Options( $c, $c->session_path() );
	$self->R_remove_samples( $c,
		{ 'Samples' => $self->{"Group_2_Sample"}->{$group_id} } );
	$c->stash->{'message'} = "removed the group $group_id\n";
	$c->res->redirect( $c->uri_for("/analyse/re_run") );
	$c->detach();
}

sub Javascript {
	my ( $self, $c ) = @_;
	return $self->Script( $c, '<script type="text/javascript" src="'.$c->uri_for('/scripts/figures.js').'"></script>');
}
1;
