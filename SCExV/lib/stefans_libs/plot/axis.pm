package axis;

#  Copyright (C) 2008 Stefan Lang

#  This program is free software; you can redistribute it
#  and/or modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation;
#  either version 3 of the License, or (at your option) any later version.

#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#  See the GNU General Public License for more details.

#  You should have received a copy of the GNU General Public License
#  along with this program; if not, see <http://www.gnu.org/licenses/>.

use stefans_libs::plot::Font;
use strict;

sub new {
	my ( $class, $which, $min_pixels, $max_pixels, $title, $resolution ) = @_;

	my ( $self, $temp );
	#Carp::confess ( "I need to know #3 and #4 which might not be defined") unless ( defined $min_pixels && defined $max_pixels);
	$self = {
		tics       => 6,             #12
		tic_length => 20,            #20
		title      => $title,
		max_pixel  => $max_pixels,
		min_pixel  => $min_pixels,
		max        => -1e+6,
		min        => +1e+6
	};

	$resolution = "large" if ( $resolution eq "max" );
	$resolution = "tiny"  if ( $resolution eq "min" );
	$resolution = "small" if ( $resolution eq "med" );

	if ( $resolution eq "large" ) {
		$self->{tics}              = 6;
		$self->{tic_length}        = 20;
		$self->{font}              = Font->new($resolution);
		$self->{tokenX_correction} = 8;
		$self->{tokenY_correction} = -6;
	}
	elsif ( $resolution eq "small" ) {
		$self->{tics}       = 8;
		$self->{tic_length} = 17;
		$self->{font}       = Font->new($resolution);
	}
	elsif ( $resolution eq "tiny" ) {
		$self->{tics}       = 6;
		$self->{tic_length} = 7;
		$self->{font}       = Font->new($resolution);
	}
	elsif ( $resolution eq "gbfeature" ) {
		$self->{tics}       = 6;
		$self->{tic_length} = 7;
		$self->{font}       = Font->new($resolution);
	}
	unless ( defined $self->{font} ) {
		warn root::identifyCaller( $class, "new" );
	}
	Carp::confess(
"So wird hier nichts geschrieben werden koennen!\nfont wurde nicht initialisiert!\nresolution = $resolution\n"
	) unless ( defined $self->{font} );
	bless $self, $class if ( $class eq "axis" );

	$self->{x_axis} = 1 == 0;
	$self->{x_axis} = 1 == 1 if ( lc($which) eq "x" );

	unless ( $self->{x_axis} ) {

		$self->{min_pixel} = $max_pixels;
		$self->{max_pixel} = $min_pixels;
	}

	return $self;

}

sub plotLabel {
	my ( $self, $image, $other_pixel, $color, $font ) = @_;

	my ( $max, $min ) = ( $self->max_value, $self->min_value );

	$self->{font} = $font unless ( defined $self->{font} );

	if ( $self->{x_axis} ) {

#print "$self: plot the label at ",$self->resolveValue($max - 0.5 * $self->{dimension}),", ",
#    $other_pixel + $self->{tic_length} ,", ", $self->resolveValue($max - 1.5 * $self->{dimension}),", ",
#    $other_pixel + $self->{tic_length} ," color: $color\n";
		my ($dimension);
		$dimension = $self->{dimension} / 2;
		$image->line(
			$self->resolveValue( $max - 0.5 * $dimension ),
			$other_pixel + 2 * $self->{tic_length},
			$self->resolveValue( $max - 1.5 * $dimension ),
			$other_pixel + 2 * $self->{tic_length},
			$color
		);
		$image->line(
			$self->resolveValue( $max - 1.5 * $dimension ),
			$other_pixel + 1.5 * $self->{tic_length},
			$self->resolveValue( $max - 1.5 * $dimension ),
			$other_pixel + 2.5 * $self->{tic_length},
			$color
		);
		$image->line(
			$self->resolveValue( $max - 0.5 * $dimension ),
			$other_pixel + 1.5 * $self->{tic_length},
			$self->resolveValue( $max - 0.5 * $dimension ),
			$other_pixel + 2.5 * $self->{tic_length},
			$color
		);
		my $string;
		$string =
		  $self->ShortenBP_digit($dimension) . " " . $self->bpScale($dimension);

		# $self, $im, $string, $x, $y, $color, $type, $angle)
		$self->{font}->plotDigitCenteredAtXY(
			$image, $string,
			$self->resolveValue( $max - $dimension ),
			$other_pixel + 2.5 * $self->{tic_length},
			$color, "gbfeature", 0
		);
	}
	else {
		my ($dimension);
		$dimension = $self->{dimension} / 2;
		$image->line(
		    $other_pixel + 2 * $self->{tic_length},
			$self->resolveValue( $max - 0.5 * $dimension ),
			$other_pixel + 2 * $self->{tic_length},
			$self->resolveValue( $max - 1.5 * $dimension ),
			$color
		);
		$image->line(
			$other_pixel + 1.5 * $self->{tic_length},
			$self->resolveValue( $max - 1.5 * $dimension ),
			$other_pixel + 2.5 * $self->{tic_length},
			$self->resolveValue( $max - 1.5 * $dimension ),
			$color
		);
		$image->line(
			$other_pixel + 1.5 * $self->{tic_length},
			$self->resolveValue( $max - 0.5 * $dimension ),
			$other_pixel + 2.5 * $self->{tic_length},
			$self->resolveValue( $max - 0.5 * $dimension ),
			$color
		);
		my $string;
		$string =
		  $self->ShortenBP_digit($dimension) . " " . $self->bpScale($dimension);

		# $self, $im, $string, $x, $y, $color, $type, $angle)
		$self->{font}->plotDigitCenteredAtXY(
			$image, $string,
			$other_pixel + 2.5 * $self->{tic_length},
			$self->resolveValue( $max - $dimension ),
			$color, "gbfeature", 0
		);
	}
	return 1;
}

sub ShortenBP_digit {
	my ( $self, $digit ) = @_;
	return undef unless ( defined $digit );
	return $digit / 1e6 if ( lc( $self->bpScale($digit) ) eq "mb" );
	return $digit / 1e3 if ( lc( $self->bpScale($digit) ) eq "kb" );
	return $digit;

	if ( $digit / 1000000 > 1 ) {
		$digit = $digit / 1000000;

		#$digit = "$digit MB";
		return $digit;
	}
	if ( $digit / 1000 > 1 ) {
		$digit = $digit / 1000;

		#$digit = "$digit KB";
		return $digit;
	}
	return $digit;
}

sub bpScale {
	my ( $self, $digit ) = @_;
	return "Mb" if ( $digit / 1e6 >= 1 );
	return "Kb" if ( $digit / 1e3 >= 1 );
	return "bp";
}

sub Bp_Scale {
	my ( $self, $set ) = @_;
	$self->{bp_scale} = 1 == 1 if ( defined $set );
	return $self->{bp_scale};
}

sub Title {
	my ( $self, $title ) = @_;
	$self->{'title'} = $title if ( defined $title );
	return $self->{'title'};
}

sub plotTitle {
	my ( $self, $image, $other_pixel, $color, $title ) = @_;

	$self->{title} = $title if ( defined $title );
	my ( $max, $min ) = ( $self->max_value, $self->min_value );
	return unless ( $self->{title} =~m/\w/ );
	if ( $self->{x_axis} ) {
		$self->{font}->plotStringCenteredAtXY(
			$image, $self->{title},
			$self->resolveValue( ( $max + $min ) / 2 ),
			$other_pixel + $self->{tic_length} * 2.5,
			$color, "gbfeature"
		);
	}

	else {
		$self->{font}->plotStringCenteredAtXY(
			$image,
			$self->{title},
			$other_pixel - $self->{tic_length} * 4,
			$self->resolveValue( ( $max + $min ) / 2 ),
			$color, "gbfeature", 90    #1.570796
		);

	}

}

=head2 redefineDigit

This function will be internally called whenever a axis is plotted - for each of the labeled positions.
You can either tell it to rescale the numbers to Bp_Scale() or previosly give this object a 
conversion table by iteratively calling convert_lable(<from>,<to>).

=cut

sub redefineDigit {
	my ( $self, $i ) = @_;

	#print "redefineDigit:\n";
	my $conversion = $self->convert_lable( $i );
	return $conversion if ( defined $conversion);
	return $i unless ( $self->Bp_Scale() );
	my @string = ( $self->ShortenBP_digit($i), " ", $self->bpScale($i) );

	#print "$self redefineDigit: ",join("",@string),"\n";
	return join( "", @string );
}

=head2 convert_lable

In case you want to define a new set of lables, but these new lables would 
interfere with the positioning of the data, you need to call the function for each
position line convert_lable( <oroiginal lable> , <changed lable> ).
After that the cahnged lables will be used for plotting!

=cut

sub convert_lable{
	my ( $self, $orig_lable, $modify_to ) = @_;
	return undef unless ( defined $orig_lable);
	$self->{'__convert_these_lables_to'} = {} unless ( ref($self->{'__convert_these_lables_to'}) eq "HASH");
	if ( defined $modify_to){
		$self->{'__convert_these_lables_to'}->{$orig_lable} = $modify_to;
	}
	return $self->{'__convert_these_lables_to'}->{$orig_lable};
}

sub plot_without_digits {

	my ( $self, $image, $other_pixel, $color, $title, $type ) = @_;
	## type 1 = first in a list of axies => suppress last tic
	## type 2 = middle axis => suppress first and last tic
	## type 3 = last in a list of axies => suppress first tic
	my ( $string, @string );
	my $test = $self->resolveValue(1);

	$self->plotTitle( $image, $other_pixel, $color, $title );

	#$self->plotLabel($image, $other_pixel, $color, $title );
	#  return 1 == 0 if ( $test < 0);
	my ( $max, $min ) = ( $self->max_value, $self->min_value );

	if ( $self->{x_axis} ) {
		$image->line(
			$self->resolveValue($max),
			$other_pixel, $self->resolveValue($min),
			$other_pixel, $color
		);
		return 1 == 0 if ( $self->{dimension} == 0 );
		Carp::confess ( "please define the type" ) unless (defined $type);
		for ( my $i = $min ; $i <= $max ; $i += $self->{dimension} ) {
			if ( $i == $min && $type == 1 ) {
				$image->line(
					$self->resolveValue($i),
					$other_pixel + $self->{tic_length},
					$self->resolveValue($i),
					$other_pixel, $color
				);
			}
			if ( $i > $min && $i < $max ) {
				$image->line(
					$self->resolveValue($i),
					$other_pixel + $self->{tic_length},
					$self->resolveValue($i),
					$other_pixel, $color
				);
			}
			if ( $i == $max && $type == 3 ) {
				$image->line(
					$self->resolveValue($i),
					$other_pixel + $self->{tic_length},
					$self->resolveValue($i),
					$other_pixel, $color
				);
			}
		}
		unless ( $type == 2 ) {
			$self->{font}->plotStringAtY_leftLineEnd(    #TinyString(
				$image, $self->redefineDigit($min),
				$self->resolveValue($min),
				$other_pixel + $self->{tic_length} * 2,
				$color, "gbfeature"
			);
			$self->{font}->plotStringAtY_rightLineEnd(    #TinyString(
				$image, $self->redefineDigit($max),
				$self->resolveValue($max),
				$other_pixel + $self->{tic_length} * 2,
				$color, "gbfeature"
			);
		}
	}

	else {

		$image->line( $other_pixel, $self->resolveValue($min),
			$other_pixel, $self->resolveValue($max), $color );
		return 1 == 0 if ( $self->{dimension} == 0 );
		for ( my $i = $min ; $i <= $max ; $i += $self->{dimension} ) {
			$image->line(
				$other_pixel - $self->{tic_length},
				$self->resolveValue($i),
				$other_pixel, $self->resolveValue($i), $color
			);
		}
	}
	return 1 == 1;
}

sub resetAxis {
	my ($self) = @_;
	$self->max_value("reset");
	$self->min->value("reset");
	return 1;
}

sub plot {

	my ( $self, $image, $other_pixel, $color, $title ) = @_;

	my $test = $self->resolveValue(1);

	$image->startGroup("axis_$self start at $test");

	$self->plotTitle( $image, $other_pixel, $color, $title );

	#  return 1 == 0 if ( $test < 0);
	my ( $max, $min ) = ( $self->max_value, $self->min_value );

	if ( $self->{x_axis} ) {
		$image->line(
			$self->resolveValue($max),
			$other_pixel, $self->resolveValue($min),
			$other_pixel, $color
		);
		return 1 == 0 if ( $self->{dimension} == 0 );
		if ( $self->{tics} == 3 ) {
			for ( my $i = $min ; $i <= $max ; $i += $self->{dimension} ) {
				$image->line(
					$self->resolveValue($i),
					$other_pixel + $self->{tic_length},
					$self->resolveValue($i),
					$other_pixel, $color
				);
			}
#			$self->{font}->plotStringAtY_leftLineEnd(    #TinyString(
#				$image, $self->redefineDigit( $self->min_value ),
#				$self->resolveValue( $self->min_value ),
#				$other_pixel + $self->{tic_length},
#				$color, "gbfeature"
#			);
#			$self->{font}->plotStringAtY_leftLineEnd(    #TinyString(
#				$image, $self->redefineDigit( $self->max_value ),
#				$self->resolveValue( $self->max_value ),
#				$other_pixel + $self->{tic_length},
#				$color, "gbfeature"
#			);
#
		}
		else {
			for ( my $i = $min ; $i <= $max ; $i += $self->{dimension} ) {
				$image->line(
					$self->resolveValue($i),
					$other_pixel + $self->{tic_length},
					$self->resolveValue($i),
					$other_pixel, $color
				);
#				$self->{font}->plotStringAtY_leftLineEnd(    #TinyString(
#					$image, $self->redefineDigit($i),
#					$self->resolveValue($i),
#					$other_pixel + $self->{tic_length},
#					$color, "gbfeature"
#				) if ( $i == $min );
#				$self->{font}->plotStringAtY_rightLineEnd(    #TinyString(
#					$image, $self->redefineDigit($i),
#					$self->resolveValue($i),
#					$other_pixel + $self->{tic_length},
#					$color, "gbfeature"
#				) if ( $i == $max );
#
#				$self->{font}->plotStringCenteredAtX(         #TinyString(
#					$image, $self->redefineDigit($i),
#					$self->resolveValue($i),
#					$other_pixel + $self->{tic_length},
#					$color, "gbfeature"
#				) if ( $i > $min && $i < $max );
			}
		}
	}

	else {

		$image->line( $other_pixel, $self->resolveValue($min),
			$other_pixel, $self->resolveValue($max), $color );
		return 1 == 0 if ( $self->{dimension} == 0 );
		for ( my $i = $min ; $i <= $max ; $i += $self->{dimension} ) {
			$image->line(
				$other_pixel - $self->{tic_length},
				$self->resolveValue($i),
				$other_pixel, $self->resolveValue($i), $color
			);

#			$self->{font}->plotDigitCenteredAtY_rightLineEnd(    #TinyString(
#				$image, $self->redefineDigit($i),
#				$other_pixel - $self->{tic_length} * 1.5,
#				$self->resolveValue($i), $color, "gbfeature"
#			);
		}
	}
	$image->endGroup();
	return 1 == 1;
}

sub getMinimumPoint {

	my ($self) = @_;
	return $self->resolveValue( $self->min_value );
}

sub defineAxis {
	my ($self) = @_;

	return $self->{PixelForValue} if ( defined $self->{PixelForValue} );

	my ( $max, $min, $dimension, $add, $temp, $tics );
	( $max, $min ) = ( $self->max_value(), $self->min_value() );
	if ( $min > $max ) {
		$self->{_max} = $min;
		$self->{_min} = $max;
		( $max, $min ) = ( $self->max_value(), $self->min_value() );
		if ( $max == $min ) {
			$max = $self->max_value( $max + 0.5 );
			$min = $self->min_value( $min - 0.5 );
		}
	}

	$dimension = $self->getDimensionInt( $self->axisLength() );
	$tics      = $self->{tics};

	#$tics = 10 if ( $tics == 3 );
	return $dimension if ( $dimension == -1 );

	#print $self->axisLength(), " dimesion = $dimension\n";

	while ( $self->axisLength / $dimension <= $tics / 2 ) {

		#	print "adjust dimension $dimension = ",$dimension / 2,"\n";
		$dimension = $dimension / 2;
	}
	while ( $self->axisLength / $dimension > $tics ) {

		#	print "adjust dimension $dimension = ",$dimension * 2,"\n";
		$dimension = $dimension * 2;
	}

	$add = 1;

	#    print
	#"defineAxis min = $min max = $max - modified (?) dimension = $dimension\n";

	$add = 0
	  if ( $min / $dimension == int( $min / $dimension )
		|| $min / $dimension > int( $min / $dimension ) );
	$min = ( int( $min / $dimension ) - $add ) * $dimension;
	$self->min_value($min);
	$add = 1;
	$add = 0
	  if ( $max / $dimension == int( $max / $dimension )
		|| $max / $dimension < int( $max / $dimension ) );
	$max = ( int( $max / $dimension ) + $add ) * $dimension;
	$self->max_value($max);
	$self->{dimension} = $dimension;

	#print "Define X Axis dimension = $dimension\n" if ( $self->{x_axis});
	#print "Define Y Axis dimension = $dimension\n" unless ( $self->{x_axis});

	return -1 if ( $dimension == 0 );

	#print "defineAxis modified ?  min = $min max = $max\n";
	#print "\$self->{dimension} = $self->{dimension}\n";
	Carp::confess(  root::get_hashEntries_as_string ($self, 2,"min_pixel is undefined in ", 100 ) ) unless ( defined $self->{min_pixel});
	Carp::confess( "max_pixel is undefined") unless ( defined $self->{max_pixel});
	Carp::confess( "axisLength is undefined") unless ( defined $self->axisLength() );
	$self->{PixelForValue} =
	  ( $self->{min_pixel} - $self->{max_pixel} ) / $self->axisLength();
	return $self->{PixelForValue};
}

sub resolveValue {
	my ( $self, $value ) = @_;
	Carp::confess("we have no value to compare between max and min!\n")
	  unless ( defined $value );
#	Carp::confess("Hey why do you want to plot a 'No Value'?")
#	  if ( $value eq "No Values" );
	if ( $value <= $self->{_max} && $value >= $self->{_min} ) {
		return
	  int( $self->{max_pixel} +
		  ( ( $self->{_max} - $value ) * $self->defineAxis() ) );
	}
	if ( $value > $self->max_value() ) {
		return $self->resolveValue( $self->max_value() );
	}
	if ( $value < $self->min_value() ) {
		return $self->resolveValue( $self->min_value() );
	}
}

sub pix2value{
	my ( $self, $value ) = @_;
	my $r = $self->max_value() - ( $value - $self->{max_pixel} ) / $self->defineAxis();
	return $r;
}

sub isOutOfRange {
	my ( $self, $value ) = @_;
	return undef unless ( defined $value );
	$value = $self->resolveValue($value);
	return ( $self->{max_pixel} > $value && $self->{max_pixel} < $value );
}

sub axisLength {
	my ($self) = @_;

	return $self->{'length'} if ( defined $self->{'length'} );
	my $length;
	$self->{'length'} = ( ( $self->max_value() - $self->min_value() )**2 )**0.5;

	#	print "new Axis Length = $self->{length}\n";
	return $self->{'length'};
}

sub Max {
	my ( $self, $max ) = @_;
	$self->{max} = $max if ( $max > $self->{max} );
	return $self->{max};
}

sub Min {
	my ( $self, $min ) = @_;
	$self->{min} = $min if ( defined $min && $min < $self->{min} );
	return $self->{min};
}

sub max_value {
	my ( $self, $max ) = @_;
	return $self->{_max} unless ( defined $max);
	if ( defined $max ) {
		if ( $max eq "reset" ) {
			$self->{_max} = undef;
			return 1;
		}
		$self->{'length'} = undef;
		$self->{_max} = $max;
		$self->{_min} = $self->{_max} unless ( defined $self->{_min} );
	}
	return $self->{_max};
}

sub min_value {
	my ( $self, $min ) = @_;
	return $self->{'_min'} unless ( defined $min);
	if ( defined $min ) {
		if ( $min eq "reset" ) {
			$self->{_min} = undef;
			return 1;
		}
		$self->{'length'} = undef;
		$self->{_min} = $min;
	}

	return $self->{_min};
}

sub getDimensionInt {
	my ( $self, $zahl ) = @_;

	#    print "getDimension $zahl\n";

	return -1 if ( $zahl == 0 );

	my ($i);
	if ( $zahl > 1 ) {
		for ( $i = 0 ; int( $zahl / 10 ) > 1 ; $i++ ) {
			$zahl = $zahl / 10;
		}
		return 10**$i    #; * int( $zahl + .5 );
	}
	if ( $zahl <= 1 ) {
		for ( $i = 1 ; int( $zahl * 10 ) < 1 ; $i++ ) {
			$zahl = $zahl * 10;
		}
		return 10**-$i;    #* (int($zahl* 10) /10) ;
	}

}

1;
