package color;

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

use strict;
use warnings;

sub new {

	my ( $class, $im, $bgColor, $rgb_array, $names ) = @_;
	warn "$class -> new() - we have not got a image to deploy the colors to..."
	  unless ( defined $im );
	my ($self);
	$bgColor = 'white' unless ( defined $bgColor );

	$self = {
		uniqueColor    => 1 == 1,
		IL7_difference => 1 == 1,
	};

	bless $self, $class if ( $class eq "color" );
	if ( -f $rgb_array ){
		open ( IN, "<$rgb_array" ) or die "I could not open the colour definition file '$rgb_array'\n$!\n";
		my @line;
		$rgb_array = undef;
		my $OK = 0;
		while ( <IN> ) {
			if ( $_ =~ m/names\tred\tgreen\tblue\n/ ) {
				$OK=1;
				$rgb_array = [];
				$names = [];
				next;
			}
			last unless ( $OK );
			chomp($_);
			@line = split("\t",$_);
			push ( @$names, shift(@line));
			push ( @$rgb_array, [@line] );
		}
		close ( IN );
	}
	$self->createColors( $im, $bgColor, $rgb_array, $names ) if ( defined $im );

	return $self;

}

sub getNextColor {
	my ($self) = @_;
	$self->{nextColor} = $self->{'next_start'} if ( $self->{nextColor} == $self->{maxColorIndex} );
	return $self->{colorArray}[ ++$self->{nextColor} ];
}

sub getDensityMapColorArray {
	my ($self) = @_;
	return (
		$self->{black},       $self->{dark_blue},  $self->{blue},
		$self->{dark_purple}, $self->{dark_green}, $self->{green},
		$self->{tuerkies1},   $self->{red},        $self->{rosa},
		$self->{yellow}
	);
}

sub UseUniqueColors {
	my ( $self, $boolean ) = @_;
	if ( defined $boolean ) {
		$self->{uniqueColor} = $boolean;
	}
	return $self->{uniqueColor};
}

sub createColors {
	my ( $self, $im, $bgColor, $rgb_array, $names ) = @_;
	$self->{im} = $im;
	$self->{'colorArray'} = [];
	$self->{nextColor}  = 0;
	my $colors;
	if ( ref($rgb_array) eq "ARRAY" ) {
		## define new colours!
		if ( ref($names) eq "ARRAY" && scalar(@$names) == scalar(@$rgb_array) )
		{
			$colors =
			  { map { @$names[$_] => @$rgb_array[$_] } 0 .. scalar(@$names)-1 };
			$colors ->{'white'} = [ 255, 255, 255 ];
			$colors ->{'black'} = [ 0, 0,0 ];
			unshift ( @$names, 'white', 'black' );
		}
	}
	else {
		$colors = {
			'white'        => [ 255, 255, 255 ],
			'grey'         => [ 183, 183, 183 ],
			'dark_grey'    => [ 100, 100, 100 ],
			'dark_purple'  => [ 155, 0,   155 ],
			'purple'       => [ 169, 0,   247 ],
			'light_purple' => [ 251, 148, 251 ],
			'black'        => [ 0,   0,   0 ],
			'dark_green'   => [ 0,   119, 10 ],
			'green'        => [ 0,   155, 0 ],
			'light_green'  => [ 0,   255, 0 ],
			'yellowgreen'  => [ 165, 202, 0 ],
			'dark_yellow'  => [ 240, 240, 40 ],
			'yellow'       => [ 255, 255, 0 ],
			'light_yelow'  => [ 255, 255, 235 ],
			'dark_blue'    => [ 0,   0,   255 ],
			'blue'         => [ 0,   155, 255 ],
			'blau2'        => [ 71,  0,   184 ],
			'tuerkies1'    => [ 0,   220, 255 ],
			'light_blue'   => [ 149, 204, 243 ],
			'red'          => [ 255, 0,   0 ],
			'rosa'         => [ 255, 0,   221 ],
			'brown'        => [ 194, 132, 80 ],
			'light_orange' => [ 255, 180, 4 ],
			'orange'       => [ 254, 115, 8 ],
			'pastel_blue'  => [ 249, 247, 255 ]
			,    ## do not change!! colors for legend! ##
			'pastel_yellow' => [ 255, 255, 230 ]
			,    ## do not change!! colors for legend! ##
			'ultra_pastel_blue' => [ 251, 251, 255 ]
			,    ## do not change!! colors for legend! ##
			'ultra_pastel_yellow' => [ 255, 255, 240 ]
			,    ## do not change!! colors for legend! ##
		};
	}
	$bgColor = 'white'
	  unless ( defined $bgColor );
	$self->{$bgColor} = $self->{im}->colorAllocate( @{ $colors->{$bgColor} } );
	unless ( $bgColor eq "white" ) {
		$im->filledRectangle( 0, 0, $im->{'width'}, $im->{'height'},
			$self->{$bgColor} );
	}
	foreach ( keys %$colors ) {
		next if ( $_ eq $bgColor );
		$self->{$_} = $self->{im}->colorAllocate( @{ $colors->{$_} } );
	}
	if (ref($names) eq "ARRAY") {
		$self->{'colorArray'} = [ map{ $self->{$_} } @$names ];
		$self->{'next_start'} = $self->{nextColor} = 1;
#		$self->{'names_array'} = $names;
#		Carp::confess ( "color data = ".root->print_perl_var_def( {map { $_ => $self->{$_}} keys %$self} ).";\n" );
	}
	else { 
		$self->{'colorArray'} = [ map{ $self->{$_} }
		qw(white purple dark_green yellowgreen dark_yellow dark_blue tuerkies1
		light_blue red rosa brown orange black green blue light_orange
		light_green ultra_pastel_blue) ];
	}
	$self->{maxColorIndex} = @{$self->{'colorArray'}};
#	Carp::confess ( "color data = ".root->print_perl_var_def( {map { $_ => $self->{$_}} keys %$self} ).";\n" );
}

sub selectTwoFoldColor {
	my ( $self, $celltype, $antibody ) = @_;
	if ( lc($celltype) =~ m/il7/ ) {
		return $self->{red} if ( lc($antibody) =~ m/h3ac/ );
		return $self->{black}
		  if ( lc($antibody) =~ m/h3k4me2/ && lc($celltype) =~ m/prob/ );
		return $self->{purple}
		  if ( lc($antibody) =~ m/h3k4me2/ && lc($celltype) =~ m/preb/ );
	}
	return $self->selectColor( $celltype, $antibody );
}

sub selectColor {
	my ( $self, $celltype, $antibody ) = @_;

 #print "\n\nDEBUG color selectColor for celltype $celltype and ab $antibody\n";
 #	if ( $self->{IL7_difference} ){
 #		if ( lc($celltype) =~ m/il7/ ){
 #			$celltype = "prot";
 #			return $self->{red};
 #		}
 #		else {
 #			$celltype = "prob";
 #		}
 #		$self->{uniqueColor} =  1 == 0;
 #	}

	if ( $self->{uniqueColor} ) {
		if ( lc($antibody) =~ m/h3ac/ ) {
			return $self->{light_green};
		}
		if ( lc($antibody) =~ m/h3k4me2/ ) {
			return $self->{dark_blue};
		}
		if ( lc($antibody) =~ m/h3k9me3/ ) {
			return $self->{red};
		}
	}
	if ( lc($celltype) =~ m/prob/ ) {
		if ( lc($antibody) =~ m/h3ac/ ) {
			return $self->{green};
		}
		if ( lc($antibody) =~ m/h3k4me2/ ) {
			return $self->{black} if ( lc($celltype) =~ m/il7/ );
			return $self->{dark_blue};
		}
		if ( lc($antibody) =~ m/h3k9me3/ ) {
			return $self->{red};
		}
		warn "no color defined for celltype $celltype and antibody $antibody\n";
		return $self->{black};
	}
	if ( lc($celltype) =~ m/preb/ ) {
		if ( lc($antibody) =~ m/h3ac/ ) {
			return $self->{dark_green};
		}
		if ( lc($antibody) =~ m/h3k4me2/ ) {
			return $self->{dark_purple};

			# return $self->{black};
		}
		if ( lc($antibody) =~ m/h3k9me3/ ) {
			return $self->{dark_purple};
		}
		warn "no color defined for celltype $celltype and antibody $antibody\n";
		return $self->{black};
	}
	if ( lc($celltype) =~ m/prot/ ) {
		if ( lc($antibody) =~ m/h3ac/ ) {
			return $self->{light_green};
		}
		if ( lc($antibody) =~ m/h3k4me2/ ) {
			return $self->{blau2};
		}
		if ( lc($antibody) =~ m/h3k9me3/ ) {
			return $self->{rosa};
		}
		warn "no color defined for celltype $celltype and antibody $antibody\n";
		return $self->{black};
	}
	if ( lc($celltype) =~ m/dc/ ) {
		if ( lc($antibody) =~ m/h3ac/ ) {
			return $self->{yellowgreen};
		}
		if ( lc($antibody) =~ m/h3k4me2/ ) {
			return $self->{tuerkies1};
		}
		if ( lc($antibody) =~ m/h3k9me3/ ) {
			return $self->{light_orange};
		}
		warn "no color defined for celltype $celltype and antibody $antibody\n";
		return $self->{black};
	}
	warn "no color defined for celltype $celltype and antibody $antibody\n";
	return $self->{black};
}

sub Token {
	my ( $self, $celltype ) = @_;
	return "I" if ( lc($celltype) =~ m/il7/ && $self->{IL7_difference} );
	return "X" if ( lc($celltype) =~ m/prob/ );
	return "E" if ( lc($celltype) =~ m/preb/ );
	return "T" if ( lc($celltype) =~ m/prot/ );
	return "D" if ( lc($celltype) =~ m/dc/ );
}

sub Colored_V_segments {
	my ( $self, $bool ) = @_;
	if ( defined $bool ) {
		$self->{use_V_segment_colors} = $bool;
	}
	return $self->{use_V_segment_colors};
}

sub highlight_Vsegment {
	my ( $self, $tag ) = @_;
	if ( defined $tag ) {
		$self->{hi_V_seg} = $tag;
	}

	#print "$self->highlight_Vsegment returns: '",
	#  substr( $self->{hi_V_seg}, 0, 10 ), "...'\n";
	return $self->{hi_V_seg};
}

sub getIg_Values {

	my ( $self, $gbFeature ) = @_;
	return $self->color_and_Name($gbFeature);
}

sub color_and_Name {
	my ( $self, $region ) = @_;

	## $region is a gbFeature!

	my ( @temp, $name, $tag, $pg, $color );

	$name = $region->Name();
	$tag  = $region->Tag();

	if ( $name =~ m/"/ ) {    #"
		@temp = split( '"', $name );
		$name = $temp[1];
	}
	## Identification by Tag
	if ( $tag eq "enhancer" ) {
		return $name, $self->{purple};
	}
	if ( $tag eq "silencer" ) {
		return $name, $self->{rosa};
	}
	if ( $tag eq "D_segment" ) {

		#     print "D_segment name = $name;\n";
		return $1,    $self->{dark_blue} if ( $name =~ m/(DQ-52)/ );
		return $1,    $self->{dark_blue} if ( $name =~ m/D_FL16.1/ );
		return $name, $self->{dark_blue} if ( $name eq "D1" || $name eq "D2" );

		$name =~ s/TR[AGDB]/IGH/;
		$name =~ m/IG[HKL](D.*?)/;
		$name = $1;

  #     print "D_segment after match against /IGH(D.*).*?=\*/  name = $name;\n";
		return $name, $self->{dark_blue};
	}
	if ( $tag eq "J_segment" ) {
		$name =~ s/TR[AGDB]/IGH/;
		$name =~ m/IG[HKL](J\d)/;
		return $1, $self->{green};
	}
	if ( $tag eq "C_region" || $tag eq "C_segment" ) {

		#	print "color : C_region  name = $name\n";
		if ( $name =~ m/(IG[HKL][\w\d]+)/ ) {
			return $1, $self->{brown};
		}
		if ( $name =~ m/TR([ABDG])C/ ) {
			return $1, $self->{brown};
		}
		return "", $self->{brown};
	}

	## Jetzt kann es nur noch eine V_region sein!
	## Alle V_regionen die nach IMGT benannt sind haben den Schlüssel V\d[1-2] als Identificator der Familie!
	## Farben wurden in Analogie zu dem paper "Johnston,...,Corcoran Ig Heavy Chain V Region" gewählt
	if ( defined $self->highlight_Vsegment() ) {
		$tag = $self->highlight_Vsegment();
		@temp = split( ";", $tag );
		foreach my $matchingFeature (@temp) {
			if ( $region->getAsGB =~ m/$matchingFeature/ ) {

#print
#"$self->color_and_Name got a V_segment ($name) and it mached to $matchingFeature\n";
				return $self->V_segment_Name($name), $self->{red};
			}
		}
		return $name, $self->{black};
	}
	if ( $self->Colored_V_segments() ) {
		print "we return the color for V_segment $name\n";
		if ( $name =~ m/V10/ || $name =~ m/VH10/ ) {
			return "V10", $self->{rosa};
		}
		if ( $name =~ m/V11/ || $name =~ m/VH11/ ) {
			return "V11", $self->{brown};
		}
		if ( $name =~ m/V12/ || $name =~ m/VH12/ ) {
			return "V12", $self->{light_orange};
		}
		if ( $name =~ m/V13/ || $name =~ m/3609N/ ) {
			return "V13", $self->{dark_green};
		}
		if ( $name =~ m/V14/ || $name =~ m/SM7/ ) {
			print
"If name = SM7 this must be printed!\nreturns V14 , $self->{blue}\n";
			return "V14", $self->{blue};
		}
		if ( $name =~ m/V15/ || $name =~ m/VH15/ ) {
			return "V15", $self->{light_blue};
		}
		if ( $name =~ m/(V1\d)/ ) {
			return $1, $self->{red};
		}
		if ( $name =~ m/V1\.\d/ || $name =~ m/J558/ ) {
			return "V1", $self->{dark_blue};
		}
		if ( $name =~ m/(V2\d)/ ) {
			return $1, $self->{red};
		}
		if ( $name =~ m/V2/ || $name =~ m/Q52/ ) {
			return "V2", $self->{green};
		}
		if ( $name =~ m/(V3\d)/ ) {
			return $1, $self->{red};
		}
		if ( $name =~ m/V3/ || $name =~ m/36-60/ ) {
			return "V3", $self->{purple};
		}
		if ( $name =~ m/V4/ || $name =~ m/X24/ ) {
			return "V4", $self->{blue};
		}
		if ( $name =~ m/V5/ || $name =~ m/7183/ ) {
			return "V5", $self->{red};
		}
		if ( $name =~ m/V6/ || $name =~ m/J606/ ) {
			return "V6", $self->{black};
		}
		if ( $name =~ m/V7/ || $name =~ m/S107/ ) {
			return "V7", $self->{orange};
		}
		if ( $name =~ m/V8/ || $name =~ m/3609/ ) {
			if ( $name =~ m/3609.\d*pg/ ) {
				$pg = "pg";
			}
			else {
				$pg = "";
			}

#       return "V8.$1$pg", $self->{orange} if ( $name =~ m/3609.\d*p?g?.(\d{1,3})/ );
			return "V8", $self->{orange};
		}
		if ( $name =~ m/V9/ || $name =~ m/VGAM3\.8/ ) {
			return "V9", $self->{light_purple};
		}

		if ( $name =~ m/(V\d+)/ ) {
			return $1, $self->{red};
		}
		if ( $name =~ m/PG/ ) {
			return "PG", $self->{black};
		}
		return "undef", $self->{blue};
	}
	else {
		return $self->V_segment_Name($name), $self->{red};
	}

}

sub V_segment_Name {
	my ( $self, $name, $tag ) = @_;

	my ( @temp, $pg );
	if ( $name =~ m/"/ ) {    #"
		@temp = split( '"', $name );
		$name = $temp[1];
	}
	return $name if ( $tag eq "enhancer" );
	return $name if ( $tag eq "silencer" );
	if ( $tag =~ m/^C_/ ) {
		return "" if ( $name =~ m/MMI/ );
		return "" if ( $name =~ m/IMGT_feature_tag/ );
		return $1 if ( $name =~ m/"([\w\d]+)"/ );
		return $name;
	}
	if ( $tag =~ m/^J_/ ) {
		return $1 if ( $name =~ m/(J\d+)/ );
		return "";
	}
	if ( $tag =~ m/^D_/ ) {
		return $1        if ( $name =~ m/(D_Q52)/ );
		return "DQ52"    if ( $name =~ m/52/ );
		return "DFL16.1" if ( $name =~ m/D-FL16.1/ );
		return "D$1"     if ( $name =~ m/TRDD(\d)/ );
		return $name     if ( $name eq "D1" || $name eq "D2" );
		return "";
		return $1 if ( $name =~ m/IGHD-(.*)/ );
		return $name;
		return "";
	}
	return "Vb13.2" if ( $name =~ m/ap. V/ );
	return $1       if ( $name =~ m/(V[abc])/ );
	return $1       if ( $name =~ m/(V\d\d[_-]?\d?)/ );
	return "V10$1"  if ( $name =~ m/V10(-?\d?)/ || $name =~ m/VH10/ );
	return "V11$1"  if ( $name =~ m/V11(-?\d?)/ || $name =~ m/VH11/ );
	return "V12$1"  if ( $name =~ m/V12(-?\d?)/ || $name =~ m/VH12/ );
	return "V13$1"  if ( $name =~ m/V13(-?\d?)/ || $name =~ m/3609N/ );
	return "V14$1"  if ( $name =~ m/V14(-?\d?)/ || $name =~ m/SM7/ );
	return "V15$1"  if ( $name =~ m/V15(-?\d?)/ || $name =~ m/VH15/ );
	return "V16$1"  if ( $name =~ m/V16(-?\d?)/ );
	return "V17$1"  if ( $name =~ m/V17(-?\d?)/ );
	return "V18$1"  if ( $name =~ m/V18(-?\d?)/ );
	return "V19$1"  if ( $name =~ m/V19(-?\d?)/ );
	return "V1$1"   if ( $name =~ m/V1(-?\d?)/ || $name =~ m/J558/ );
	return "V20$1"  if ( $name =~ m/V20(-?\d?)/ );
	return "V21$1"  if ( $name =~ m/V21(-?\d?)/ );
	return "V22$1"  if ( $name =~ m/V22(-?\d?)/ );
	return "V24$1"  if ( $name =~ m/V24(-?\d?)/ );
	return "V25$1"  if ( $name =~ m/V25(-?\d?)/ );
	return "V26$1"  if ( $name =~ m/V26(-?\d?)/ );
	return "V27$1"  if ( $name =~ m/V27(-?\d?)/ );
	return "V28$1"  if ( $name =~ m/V28(-?\d?)/ );
	return "V29$1"  if ( $name =~ m/V29(-?\d?)/ );
	return "V2$1"   if ( $name =~ m/V2(-?\d?)/ || $name =~ m/Q52/ );
	return "V30$1"  if ( $name =~ m/V30(-?\d?)/ );
	return "V31$1"  if ( $name =~ m/V31(-?\d?)/ );
	return "V32$1"  if ( $name =~ m/V32(-?\d?)/ );
	return "V34$1"  if ( $name =~ m/V34(-?\d?)/ );
	return "V35$1"  if ( $name =~ m/V35(-?\d?)/ );
	return "V36$1"  if ( $name =~ m/V36(-?\d?)/ );
	return "V37$1"  if ( $name =~ m/V37(-?\d?)/ );
	return "V38$1"  if ( $name =~ m/V38(-?\d?)/ );
	return "V39$1"  if ( $name =~ m/V39(-?\d?)/ );
	return "V3$1"   if ( $name =~ m/V3(-?\d?)/ || $name =~ m/36-60/ );
	return "V4$1"   if ( $name =~ m/V4(-?\d?)/ || $name =~ m/X24/ );
	return "V5$1"   if ( $name =~ m/V5(-?\d?)/ || $name =~ m/7183/ );
	return "V6$1"   if ( $name =~ m/V6(-?\d?)/ || $name =~ m/J606/ );
	return "V7$1"   if ( $name =~ m/V7(-?\d?)/ || $name =~ m/S107/ );
	return "V8$1"   if ( $name =~ m/V8(-?\d?)/ || $name =~ m/3609/ );
	return "V9$1"   if ( $name =~ m/V9(-?\d?)/ || $name =~ m/VGAM3\.8/ );
	return ""       if ( $name =~ m/(D)/ );
	return $1       if ( $name =~ m/J(\d+)/ );
	return $1 if ( $name =~ m/(IG\w)/ || $name =~ m/C([ABDG])/ );
	return "V?";
}

1;
