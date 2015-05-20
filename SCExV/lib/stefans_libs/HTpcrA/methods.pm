package stefans_libs::HTpcrA::methods;

#  Copyright (C) 2014-06-24 Stefan Lang

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

#use FindBin;
#use lib "$FindBin::Bin/../lib/";
use strict;
use warnings;

=for comment

This document is in Pod format.  To read this, use a Pod formatter,
like 'perldoc perlpod'.

=head1 NAME

stefans_libs::HTpcrA::methods

=head1 DESCRIPTION

This creates a section in the zip data report that describes what has been done with the data.

=head2 depends on


=cut

=head1 METHODS

=head2 new

new returns a new object reference of the class stefans_libs::HTpcrA::methods.

=cut

sub new {

	my ($class) = @_;

	my ($self);

	$self = {};

	bless $self, $class if ( $class eq "stefans_libs::HTpcrA::methods" );

	return $self;

}

=head2 html_methods ( HTpcrA_object )

This object creates a html page describing what has been done with the data so far.
I wonder whether I can use TT for that....

No that is going to be too complicated....

=cut

sub html_methods {
	my ( $self, $c, $html ) = @_;
	## there is only a list of controler functions that do store there options:
	## 'analysis' => 'index' and 'files' => 'upload'
	my $path = $c->session_path();
	system( "mkdir " . $path . "html/" );

	$html ||= '';
	$html .="<h1>Methods</h1>\n\n";
	if ( -f $path . "preprocess/Preprocess.Configs.txt" ) {
		$html .= "<h2>Preprocessing</h2>\n"
		  . $self->write_descriptions( $c, 'files', 'upload',
			$path . "preprocess/Preprocess.Configs.txt" );
	}
	else {
		$html .= "<h2>Preprocessing</h2>\n"
		  . "<p>Sorry it seams as if you did neither upload any data not pre-process and data. Hence I can not give you any pre-processing settings here.</p>\n\n";
	}
	if ( -f $path . "rscript.Configs.txt" ) {
		$html .= "<h2>Analyse</h2>\n"
		  . $self->write_descriptions( $c, 'analyse', 'index',
			$path . "rscript.Configs.txt" );
	}
	else {
		$html .= "<h2>Analyse</h2>\n"
		  . "<p>Sorry I could not find analysis settings in your data set.</p>\n\n";
	}

	# 1d and 2d gene groups are included later.
#	Carp::confess($html);
	return $self->html_from_str($html);
}

sub write_descriptions {
	my ( $self, $c, $controler, $function, $file ) = @_;
	my $path = $c->session_path();
	unless ( -f $path . "html/help.gif" ) {
		system( "cp $path"
			  . "../../static/images/Questions.gif $path"
			  . "html/help.gif" );
	}
	my $str = "<h3>$function</h3\n\n><ul>";
	unless ( open( IN, "<$file" ) ) {
		$str .= $!;
		return $str;
	}
	my ( @line, $text, $help_html_f );
	unless ( $c->model('HelpFile')->controller() ) {
		$c->model('HelpFile')
		  ->read_file( $c->config->{'root'} . "/help/help_strings.xls" );
	}
	while (<IN>) {
		chomp($_);
		@line = split( "\t", $_ );

		$text =
		  $c->model('HelpFile')->HelpText( $controler, $function, $line[0] );
#		Carp::confess( "I got this text : '$text' from the object "
#			  . $c->model('HelpFile')
#			  . "->HelpText( $controler, $function,$line[0] )" );
		if ( $text =~ m/\w/ ) {
			$help_html_f =
			  "html/" . join( "_", $controler, $function, $line[0] ) . ".html";
			open( HTMP, ">$path" . $help_html_f );
			print HTMP $self->html_from_str($text);
			close(HTMP);
			$str .=
"<li>$line[0] <a href='./$help_html_f', taget='_blank'><img style='border:0px;' src='./html/help.gif' width =20px></a></br>\n"
			  . "Your selection: '$line[1]'\n</li>\n";
		}
	}
	close(IN);
	$str .= "</ul>\n";
	return $str;

}

sub html_from_str {
	my ( $self, $str, $title ) = @_;
	return '<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8" />
<title>' . $title . '</title>
</head>
<html>
<body>
<p>'. $str
	  . '</body>
</html>'
}

1;
