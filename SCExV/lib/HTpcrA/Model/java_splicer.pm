package HTpcrA::Model::java_splicer;
use Moose;
use namespace::autoclean;

use Digest::MD5 qw(md5_hex);

extends 'Catalyst::Model';

=head1 NAME

HTpcrA::Model::java_splicer - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.


=encoding utf8

=head1 AUTHOR

Stefan Lang

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

sub look_for {
	my ( $self, $pattern, $end, $strings ) =@_;
	my ( @functions, @md5sums, $function, $count, $tmp, $use, @rest );
	$use = 0;
	foreach ( @$strings ){
		$use = 1 if( $_ =~ m/$pattern/ );
		$tmp .= $_."\n" if ( $use);
		push ( @rest, $_) unless ( $use );
		if ( $_ =~ m/$end/ ) {
			if ( $tmp =~ m/\w/ ) {
				push ( @functions, $tmp);
				push ( @md5sums,   &md5_hex($tmp) );
				$tmp = '';
			}
			$use = 0;
		}
	}
	return \@functions, \@md5sums, \@rest;
}

sub java_splice_old {
	my ( $self, $str ) = @_;
	## first splice the <script id="[fv]shader's
	my ( @functions, @md5sums, $all, @ret );
	$str =~ s/<script src="CanvasMatrix.js" type="text\/javascript"><\/script>//; ## this has to be included once!
	$all =  [split("\n", $str)];
 	@ret = $self-> look_for('<script id="', '\/script>', $all );
 	push( @functions, @{$ret[0]} );
 	push( @md5sums, @{$ret[1]} );
	$all = $ret[2];
	
	## now I have only one script left - the plot specific one...
	@ret = $self-> look_for('<script', '\/script>', $all );	
	$all = $ret[2];
	$str = java_splice ( $ret[0] ); ## I want to get the single fucntions here!
	push( @functions, @{$str->{'functions'}} );
 	push( @md5sums, @{$str->{'md5sums'}} );
	return  { functions => \@functions, md5sums=> \@md5sums, rest =>join("\n",@$all) } ; ## the last entry is the plot script
}

sub classSplitter {
	my ( $self, $str ) = @_;
	my (@return, $use, $position);
	$position = -1;
	if ( -f $str ) {
		open ( IN, "<$str" ) or die $!;
		$str = join("\n", <IN> );
		close (IN ); 
	}
	foreach ( split( "\n", $str ) ){
		if ( $_ =~ m/^<script>/ ){
			$position ++;
			$return[$position] = '';
			$use = 1;
			next;
		}
		if ( $_ =~ m/^<\/script>/ ) {
			$use = 0;
			next;
		}
		$return[$position] .= "$_\n" if ( $use );
	}
	return @return; 
}

sub java_splice {
	my ( $self, $str ) = @_;
	my ( @functions, @md5sums, $function, $count, $tmp );
	$function = '';
	$count    = 0;
	foreach ( split( "\n", $str ) ) {
		if ( $_ =~ m/{/ ) {
			$count++;
		}
		if ( $count > 0 ) {
			$function .= $_ . "\n";
		}
		if ( $_ =~ m/}/ ) {
			$count--;
		}
		if ( $count == 0 ) {
			## if there is still a function in that I need to process that!
			if ( scalar( $function =~ m/ function\s\([ \w\.]+\)\s*{/g ) > 1 ) {
				$tmp = $self->java_splice($function);
				push( @functions, @{ $tmp->{'functions'} } );
				push( @md5sums,   @{ $tmp->{'md5sums'} } );
				$function = '';
			}
			elsif ($function) {
				push( @functions, $function );
				push( @md5sums,   &md5_hex($function) );
				$function = '';
			}
			else {
				push( @functions, $_ . "\n" );
				push( @md5sums,   &md5_hex($_) );
			}
		}
	}
	return { functions => \@functions, md5sums => \@md5sums };
}

sub read_webGL {
	my ( $self, $fname ) = @_;
	open ( IN, "<".$fname) or Carp::confess( "file not found: $fname\n". $!);
	my $tmp = '';
	my $file = "";
	my $use = 0;
	while ( <IN> ){
		$file = $1 if ( $_ =~ m/<body onload="(.*;)">/ );
		$use = 1 if ( $_ =~ m/div align="center"/ );
		$use = 0 if ( $_ =~ m/<p id="K?debug">/ );
		#next if ( $_ =~ m/CanvasMatrix4=function\(m\)/ );
		$tmp .= $_ if ($use);
	}
	close ( IN );
	return( $tmp, $file );
}

sub getDIV {
	my ( $self, $fname ) = @_;
	open ( IN, "<".$fname) or Carp::confess( "file not found: $fname\n". $!);
	my $tmp = '';
	my $file = "";
	my $use = 0;
	while ( <IN> ){
		$file = $1 if ( $_ =~ m/<body onload="(.*;)">/ );
		$use = 1 if ( $_ =~ m/<div .* class="rglWebGL"/ );
		$use = 0 if ( $_ =~ m/<p id="K?debug">/ );
		#next if ( $_ =~ m/CanvasMatrix4=function\(m\)/ );
		$tmp .= $_ if ($use);
	}
	close ( IN );
	$tmp .= "</div>\n";
	return( $tmp, $file );
}


sub drop_duplicates {
	my ( $self, $str1, $str2, $keep_html ) = @_;
	$str1 = $self->java_splice($str1) unless ( ref($str1) eq "HASH" );
	$str2 = $self->java_splice($str2) unless ( ref($str2) eq "HASH" );
	my $already_existing = { map { $_ => 1 } @{ $str1->{'md5sums'} } };
	my $last_matched_div = 0;
	my ( @duplicates, $tmp );
	for ( my $i = @{ $str2->{'functions'} } - 1 ; $i >= 0 ; $i-- ) {
		if ( $already_existing->{"@{$str2->{'md5sums'}}[$i]"} ) {
			$tmp = splice( @{ $str2->{'functions'} }, $i, 1 );
			$tmp = join(
				"\n",
				map {
					my $t = $_;
					if ( $t =~ m/CanvasMatrix4=function\(m\)/ ) {
						$t = join( "{",
							map { my $tm = $_; $tm =~ s/<\/?script>//sg; $tm }
							  split( "{", $t ) )."\n";
					}
					else { $t =~ s/<.+?>//sg; }
					$t
				} split( "\n", $tmp )
			) unless ( $keep_html );
			push( @duplicates, $tmp );
			splice( @{ $str2->{'md5sums'} }, $i, 1 );
		}
	}
	my @tmp = split("\n", join( "", @{ $str2->{'functions'} } ));
	my $part = join("\n", $tmp[0], '<script type="text/javascript">', @tmp[1..(@tmp-1)], '</script>' )."\n";
	
	return join( "", @{ $str1->{'functions'} } ), $part, join( "", reverse @duplicates );
}

__PACKAGE__->meta->make_immutable;

1;
