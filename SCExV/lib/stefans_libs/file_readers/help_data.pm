package stefans_libs::file_readers::help_data;

use strict;
use warnings;

use stefans_libs::flexible_data_structures::data_table;

sub new {
	my ( $class, $file ) = @_;
	$file ||= '';
	my $self = {
		'file' => $file,
		'data' => {},
	};
	bless $self, 'stefans_libs::file_readers::help_data';
	$self->{'data'}->read_file($file) if ( -f $file );
	return $self;

}

sub read_file {
	my ( $self, $file ) = @_;
	$self->{'file'} = $file if ( -f $file);
	my $ret = data_table->new();
	$ret->read_file($file);
	$self->{'data'} = {};
	$self->{'index'} = {};
	my $i = 0;
	foreach ( @{ $ret->GetAll_AsHashArrayRef() } ) {
		$self->{'data'}->{ $_->{'controller'} } = {}
		  unless ( defined $self->{'data'}->{ $_->{'controller'} } );
		$self->{'data'}->{ $_->{'controller'} }->{ $_->{'function'} } = {}
		  unless (
			defined $self->{'data'}->{ $_->{'controller'} }
			->{ $_->{'function'} } );
		$self->{'data'}->{ $_->{'controller'} }->{ $_->{'function'} }
		  ->{ $_->{'variable'} } = $_->{'text'};
		$self->{'index'}
		  ->{ $_->{'controller'} . $_->{'function'} . $_->{'variable'} } = $i++;
	}
	return $self;
}

sub controller {
	my ($self) = @_;
	return scalar( keys %{ $self->{'data'} } );
}

sub HelpText {
	my ( $self, $c, $controler, $function, $variable ) = @_;
	my @probs =
	  eval { return $self->{'data'}->{$controler}->{$function}->{$variable}; };
	return $probs[0]. "</br><button onclick=\"window.close();return false;\">Close page</button> ";
}

sub AddData {
	my ( $self, $controler, $function, $variable, $text ) = @_;
	my $ret = data_table->new( { 'filename' => $self->{'file'} } );
	if ( defined $self->{'index'}->{ $controler . $function . $variable } ) {
		unless (
			$text eq @{
				@{ $ret->{'data'} }
				  [ $self->{'index'}->{ $controler . $function . $variable } ]
			}[3]
		  )
		{
			@{ @{ $ret->{'data'} }
				  [ $self->{'index'}->{ $controler . $function . $variable } ] }
			  [3] = $text;
			$ret->write_file( $self->{'file'} );
			$self->read_file( $self->{'file'} );
		}
	}
	else {
		$ret->AddDataset(
			{
				'controller' => $controler,
				'function'   => $function,
				'variable'   => $variable,
				'text'       => $text
			}
		);
		$ret->write_file( $self->{'file'} );
		$self->read_file( $self->{'file'} );
	}
	return 1;
}

1;
