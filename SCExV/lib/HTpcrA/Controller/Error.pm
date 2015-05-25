package HTpcrA::Controller::Error;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

HTpcrA::Controller::Error - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

sub emit {
	my ( $class, $c, $output ) = @_;

	my $path = $c->session_path();
	open( OUT, ">$path/Error_system_message.txt" );
	print OUT join( "", @{ $c->error() } ) . $class;
	close(OUT);
	$c->clear_errors();
	$c->res->redirect( $c->uri_for( "/error/index/" ) );
	return 1;
}

sub index : Local : Form {
	my ( $self, $c ) = @_;
	my $path = $c->session_path();
	$c->model('Menu')->Reinit();
	$c->cookie_check();
	my $form_array = [];
	push(
		@{$form_array},
		{
			'name'  => 'text',
			'type'  => 'textarea',
			'cols'  => 80,
			'rows'  => 20,
			'value' => '',
		}
	);
	push(
		@{$form_array},
		{
			'name'    => 'report_error',
			'options' => [ { '1' => 'Yes' }, { '0' => 'No' } ],
			'value'   => '1',
		}
	);
	foreach ( @{$form_array} ) {
		$c->form->field( %{$_} );
	}
	if ( $c->form->submitted && $c->form->validate ) {
		my $dataset = $c->form->fields();
		if ( $dataset->{'text'} =~ m/\w/ ) {
			open( OUT, ">", $c->session_path() . "Error_user_message.txt" );
			print OUT $dataset->{'text'};
			close(OUT);
		}
		my $filename = 'Error_report_'
		  . join(
			"_",
			split(
				/[\s:]+/,
				DateTime::Format::MySQL->format_datetime(
					DateTime->now()->set_time_zone('Europe/Berlin')
				)
			)
		  ) . '.zip';
		system(
			"cd " . $c->session_path() . "\nrm *.zip\nzip -9 -r $filename *" );
		system( "mv "
			  . $c->session_path()
			  . "$filename "
			  . $c->session_path()
			  . "../" );
		if ( -f '/usr/local/bin/report_SCexV_error.pl' ) {
			system( '/usr/local/bin/report_SCexV_error.pl -error_file '
				  . $c->session_path()
				  . "../$filename" );
		}
		$c->res->redirect( $c->uri_for("/files/upload/") );
		$c->detach();
	}
	$c->stash->{'errorfile'} =
	  $c->uri_for( '/error/error' );
	open( IN, "<$path/Error_system_message.txt" );
	my @err = <IN>;
	$c->stash->{'error'} = join( "", @err[ 0 .. 3 ] );
	close(IN);
	$c->stash->{'template'} = 'report_error.tt2';
}

sub error : Local {
	my ( $self, $c ) = @_;
	my $path = $c->session_path();
	$c->model('Menu')->Reinit();
	$c->cookie_check();
	if ( -f "$path/Error_system_message.txt" ) {
		open( IN, "<$path/Error_system_message.txt" );
		$c->stash->{'error'} = join( "</br>", <IN> );
		close(IN);
	}
	else {
		$c->stash->{'error'} = "No error message available";
	}
	if ( -f $path."back_to.txt") {
		open ( IN ,"<".$path."back_to.txt");
		my @to = <IN>;
		close ( IN );
		chomp($to[0]);
		$c->stash->{'back'} = $c->uri_for($to[0]);
	}
	$c->stash->{'template'} = 'error.tt2';
}

=head1 AUTHOR

Stefan Lang

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
