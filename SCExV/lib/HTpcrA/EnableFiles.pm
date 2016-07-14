package HTpcrA::EnableFiles;

use Moose::Role;

sub rgbToHex {
	my ( $self, $red, $green, $blue ) = @_;
	my $string = sprintf( "#%2.2X%2.2X%2.2X", $red, $green, $blue );
	return ($string);
}

=head2 colors_rgb ( $c, $path )

returns an array of arrays containing RGB values for the groups 1 to n

convert to hex by 

map{ $self->rgbToHex ( @$_ ) } $self->colors_rgb( $c, $path);

=cut

sub colors_rgb {
	my ( $self, $c, $path ) = @_;
	my @colors;
	my $fname = "$path" . "2D_data_color.xls";
	if ( -f $fname ) {
		open( IN, "<$fname" ) or Carp::confess("$!\n");
		my ( $known, @tmp );
		while (<IN>) {
			next if ( $_ =~ m/red/ );
			chomp($_);
			$_ =~ s/"//g;
			@tmp = split( " ", $_ );
			$tmp[0] = $self->rgbToHex( @tmp[ -4, -3, -2 ] );
			next if ( $known->{ $tmp[0] } );
			push( @colors, [ @tmp[ -4, -3, -2 ] ] );
			$known->{ $tmp[0] } = 1;
		}
		close(IN);
	}
	else {
		Carp::confess( "Internal server error - the file $path"
			  . "2D_data_color.xls does not exist!" );
	}
	return @colors;
}

sub check {
	my ( $self, $c, $what ) = @_;
	$what ||= 'analysis';
	my $path = $c->session_path();
	unless ( $what eq 'nothing' ) {
		unless ( -f $path . "/norm_data.RData" ) {
			$c->res->redirect( $c->uri_for("/files/upload/") );
			$c->detach();
		}
	}
	if ( $what eq 'analysis' ) {
		unless ( -d $path . 'webGL' ) {
			$c->res->redirect( $c->uri_for("/analyse/") );
			$c->detach();
		}
	}
	$c->model('Menu')->Reinit();
	$self->file_upload( $c, {} );
	$c->cookie_check();
	return $path;
}

sub colors_Hex {
	my ( $self, $c, $path ) = @_;
	my @colors;
	my $fname = "$path" . "2D_data_color.xls";
	if ( -f $fname ) {
		open( IN, "<$fname" ) or Carp::confess("$!\n");
		my ( $known, @tmp );
		while (<IN>) {
			next if ( $_ =~ m/red/ );
			chomp($_);
			$_ =~ s/"//g;
			@tmp = split( " ", $_ );
			$tmp[0] = $self->rgbToHex( @tmp[ -4, -3, -2 ] );
			next if ( $known->{ $tmp[0] } );
			push( @colors, $tmp[0] );
			$known->{ $tmp[0] } = 1;
		}
		close(IN);
		my $session_hash = $c->session();
		foreach my $filetype ( 'PCRTable', 'PCRTable2', 'facsTable' ) {
			if ( defined $session_hash->{$filetype} ) {
				map {
					@{ $session_hash->{$filetype} }[$_]->{'color'} = $colors[$_]
					  if (
						ref( @{ $session_hash->{$filetype} }[$_] ) eq "HASH" );
				} 0 .. ( @colors - 1 );
			}
		}
	}
	else {
		Carp::confess( "Internal server error - the file $path"
			  . "2D_data_color.xls does not exist!" );
	}
	return @colors;
}

sub init_file_cookie {
	my ( $self, $c, $force ) = @_;
	$force ||= 0;
	my $session_hash = $c->session();
	unless ( defined $session_hash ) {
		return 0;
	}
	if ($force) {
		map { $session_hash->{$_} = [] } 'PCRTable', 'PCRTable2', 'facsTable';
	}
	else {
		map {
			$session_hash->{$_} = []
			  unless ( ref( $session_hash->{$_} ) eq "ARRAY" )
		} 'PCRTable', 'PCRTable2', 'facsTable';
	}
	return $session_hash;
}

sub file_upload {
	my ( $self, $c, $processed_form ) = @_;
	my $session_hash = $self->init_file_cookie($c);
	unless ($session_hash) {
		return 0;
	}
	my $files = 0;
	my $unique;
	$self->{'new_files'} = 0;
	foreach my $filetype ( 'PCRTable', 'PCRTable2', 'facsTable' ) {
		for ( my $i = @{ $session_hash->{$filetype} } ; $i >= 0 ; $i-- ) {
			next unless ( defined @{ $session_hash->{$filetype} }[$i] );
			unless ( -f @{ $session_hash->{$filetype} }[$i]->{'total'} ) {
				splice( @{ $session_hash->{$filetype} }, $i, 1 );
			}
		}
		$unique =
		  { map { $_->{'filename'} => 1 } @{ $session_hash->{$filetype} } };
		if ( defined $processed_form->{$filetype} ) {
			## I might have some arrays here
			foreach my $new_file (
				map {
					if   ( ref($_) eq "ARRAY" ) { @$_ }
					else                        { $_ }
				} $processed_form->{$filetype}
			  )
			{
				my $tmp;
				if ( -f $new_file->{'total'}
					&& !$unique->{ $new_file->{'filename'} } )
				{
					($new_file) =
					  $self->file_format_fixes( $c, $new_file, $unique,
						$filetype );
					push( @{ $session_hash->{$filetype} }, $new_file );
					$self->{'new_files'} = 1;
				}
			}
			if ( $self->{'new_files'} ) {
				$session_hash->{$filetype} =
				  $self->order_files( $session_hash->{$filetype},
					$processed_form );
			}
		}
		$files += @{ $session_hash->{$filetype} };
		$c->stash->{$filetype} = $session_hash->{$filetype};
	}

	#	if ( $self->{'new_files'} ) {
	#		system( 'find '
	#			  . $c->session_path()
	#			  . " -name '*svg' -o -name '*png' exec rm {} \\;" );
	#	}
	return $files;
}

sub order_files {
	my ( $self, $files, $processed_form ) = @_;
	return $files unless ( defined $processed_form->{'orderKey'} );
	return [
		sort {
			my ($A) = $a->{'filename'} =~ m/$processed_form->{'orderKey'}(\d+)/;
			my ($B) = $b->{'filename'} =~ m/$processed_form->{'orderKey'}(\d+)/;
			$A <=> $B;
		  } @{$files}
	];
}

sub file_format_fixes {
	my ( $self, $c, $filename, $unique, $filetype ) = @_;
	## to get rid of this line ending problems:
	unless ( ref($filename) eq "HASH" ) {
		$filename = root->filemap($filename);

	}

	my $outfile = $filename;
	$outfile = root->filemap(
		join( "/",
			$filename->{'path'},
			join( "_", split( /\s+/, $filename->{'filename'} ) ) )
	);
	unless ( $outfile->{'total'} eq $filename->{'total'} ) {
		system("cp '$filename->{'total'}' '$outfile->{'total'}'");
		$filename = $outfile;
		$unique->{ $filename->{'filename'} } = 1;
	}

	system("/usr/bin/dos2unix -q '$filename->{'total'}'");
	system("/usr/bin/dos2unix -q -c mac '$filename->{'total'}'");

	## bloody hack to get rid of the stupid ...3","23,43","32.... format problems
	$self->__fix_file_problems( $filename->{'total'}, $filetype );

	return ($filename);
}

sub __fix_file_problems {
	my ( $self, $filename, $filetype ) = @_;
	open( OUT, ">$filename.mod" )
	  or
	  Carp::confess("I could not open the outfile '$filename.mod'\nError: $!");
	open( IN, "<$filename" );
	if ( $filetype eq "facsTable" ) {
		my $rep;
		## 1,000 == 1000 !!!!!!!
		while (<IN>) {
			foreach my $problem ( $_ =~ m/(["']-?\d+,\d+,?\d*["'])/g ) {
				$rep = $problem;
				$rep =~ s/["',]//g;
				$_   =~ s/$problem/$rep/;
			}
			print OUT $_;
		}
	}
	else {
		while (<IN>) {
			$_ =~ s/;"?(\d+)[\.,](\d+)"?;+?/;$1.$2;/g;
			$_ =~ s/;/,/g;
			print OUT $_;
		}
	}

	close(IN);
	close(OUT);
	system("mv '$filename.mod' '$filename'");
	return 1;
}

sub process_files_to_R {
	my ( $self, $c, $object_name ) = @_;

	#'PCRTable' or 'facsTable'
	my $str      = "$object_name <- NULL\n";
	my $path_add = '';
	$path_add = "../" unless ( $self->path($c) eq $c->session_path() );
	$self->{'R_file_read'} = '';
	if ( -f $c->session_path() . $object_name . '.data' )
	{    ## the restricted data tables
		$self->{'R_file_read'} = $path_add . $object_name . '.data';
		$str = "$object_name <-  read.table('$self->{'R_file_read'}')\n"
		  . "$object_name.d<- as.matrix($object_name)\n";
	}
	elsif ( -f $c->session_path() . 'merged_' . $object_name . '.xls' ) {
		$self->{'R_file_read'} = $path_add . 'merged_' . $object_name . '.xls';
		$str =
		    "$object_name <-  read.delim('$self->{'R_file_read'}',header=T)\n"
		  . "$object_name.d <- as.matrix($object_name"
		  . "[,2:ncol($object_name)])\n"
		  . "rownames($object_name.d) <- $object_name"
		  . "[,1]\n";
	}
	elsif ( !defined $c->session->{$object_name} ) {
		$c->stash->{'message'} =
		  "Session has ended - please start from scratch!\n";
		$c->res->redirect( $c->uri_for("/files/upload/") );
		$c->detach();
	}
	elsif ( @{ $c->session->{$object_name} } > 0 ) {
		$self->{'R_file_read'} =
		  $path_add . @{ $c->session->{$object_name} }[0]->{'file'};
		$str =
		    "$object_name <-  read.delim('$self->{'R_file_read'}',header=T)\n"
		  . "$object_name.d <- as.matrix($object_name"
		  . "[,2:ncol($object_name)])\n"
		  . "rownames($object_name.d) <- $object_name"
		  . "[,1]\n";
	}
	return $str;
}

sub defined_or_set_to_default {
	my ( $self, $new, $default ) = @_;
	map { $new->{$_} ||= $default->{$_} } keys %$default, keys %$new;
	return $new;
}

sub config_file {
	my ( $self, $c, $filename, $hash ) = @_;
	Carp::confess("I need the filename here!\n")
	  unless ( defined $filename );
	$filename = $self->path($c) . $filename;
	if ( -f $filename and !( ref($hash) eq "HASH" ) ) {
		open( CONF, "<$filename" )
		  or Carp::confess "I could not open the config file '$filename'\n$!\n";
		my ( $configs, @line, $key );
		while (<CONF>) {
			next if ( $_ =~ m/^#/ );
			chomp($_);
			@line = split( "\t", $_ );
			$key = shift(@line);
			if ( @line == 1 ) {
				$configs->{$key} = $line[0];
			}
			else {
				$configs->{$key} = [@line];
			}
		}
		close(CONF);
		return $configs;
	}
	elsif ( ref($hash) eq "HASH" ) {
		open( CONF, ">$filename" )
		  or Carp::confess
		  "I could not create the config file '$filename'\n$!\n";
		while ( my ( $key, $value ) = each %$hash ) {
			print CONF $key . "\t";
			if ( ref($value) eq "ARRAY" ) {
				print CONF join( "\t", @$value ) . "\n";
			}
			else {
				print CONF $value . "\n";
			}
		}
		close(CONF);
		return 1;
	}
	unless ( -f $filename ) {
		return $self->init_dataset()
		  ;    # tried to read without the file being present
	}
	Carp::confess( "Did not know what to do with  $filename, $hash !\nkeys:",
		join( "\n", keys %$hash ) . "\n" );
}

sub init_dataset {
	return {

	};
}

sub __check_uploaded_files {
	my ( $self, $c ) = @_;
	my $i    = 0;
	my $test = data_table->new();
	my $fn;
	## here I need to check whether the files are tab separated tables.
	## I need the same genes in all the different tables
	$self->{'samples_in_file'} = [];
	foreach my $type ( 'PCRTable', 'facsTable' ) {
		my $header;
		my $merged;
		for ( my $id = @{ $c->session->{$type} } - 1 ; $id > -1 ; $id-- ) {
			$fn = @{ $c->session->{$type} }[$id]->{'filename'};
			unless ( -f $fn ) {
				$self->reject_file( $c, $type, $id,
					"The file could not be accessed on the server." );
				next;
			}
			eval {
				$test =
				  data_table->new( { 'filename' => $c->session_path() . $fn } );
			};
			if ( @{ $test->{'header'} }[0] =~ m/Chip Run Info/ ) {
				$test =
				  $c->model('PCR_Raw_Files')->new()->Sample_Postfix(".P$id");
				$test->read_file( $c->session_path() . $fn );
				if ( $test->{'control_data_table'}->Lines() > 0 ) {
					$test->{'control_data_table'}->write_file(
						$c->session_path() . $type . '_cntrl_' . $id . ".xls" );
				}
				$test = $test->{'data_table'};
			}
			unless ( $test->Lines() > 0 ) {
				$self->reject_file( $c, $type, $id,
					"Failed to read data - not a supported tab separated file ("
					  . $c->session_path()
					  . $fn
					  . ")" );
				next;
			}
			$header = $test->{'header'}
			  unless ( defined $header );
			my $error = $self->header_match( $header, $test->{'header'} );
			if ( $error =~ m/\w/ ) {
				$self->reject_file( $c, $type, $id, $error );
				next;
			}
			@{ $self->{'samples_in_file'} }[$id] = $test->Rows();
			unless ( ref($merged) eq "data_table" ) {
				$merged = $test->copy();
				next;
			}
			unshift( @{ $merged->{'data'} }, @{ $test->{'data'} } );
		}
		$i += @{ $c->session->{$type} };
		$merged->write_file( $c->session_path() . "merged_$type.xls" )
		  if ( ref($merged) eq "data_table" );
	}
	return $i;
}

sub header_match {
	my ( $self, $a, $b ) = @_;
	my $error = '';
	for ( my $i = 0 ; $i < @$a ; $i++ ) {
		$error .= "pos $1 mismatch '@$a[$i]' != '@$b[$i]'\n"
		  unless ( @$a[$i] eq @$b[$i] );
	}
	$error =
	  "\nGene names and/or gene order do not match.\nPlease check and resubmit."
	  if ( $error =~ m/\w/ );
	return $error;
}

sub reject_file {
	my ( $self, $c, $type, $id, $message, $processed_form ) = @_;
	$c->stash->{'message'} .=
	  @{ $c->session->{$type} }[$id]->{'filename'} . ": " . $message . "\n";
	splice( @{ $c->session->{$type} }, $id, 1 );
	return 1;
}

sub filemap {
	shift->parse_path(@_);
}

sub parse_path {
	my ( $self, $filename ) = @_;
	my @temp = split( "/", $filename );
	my $ret = {};
	$ret->{'file'}     = $filename;
	$ret->{'filename'} = pop(@temp);
	$temp[0] = "./" unless ( defined $temp[0] );
	$ret->{'path'} = join( "/", @temp );
	@temp = split( /\./, $ret->{'filename'} );
	$ret->{'filename_base'} = $temp[0];
	$ret->{'filename_ext'}  = pop(@temp);

	if ( @temp == 0 ) {
		$ret->{'filename_core'} = $ret->{'filename_ext'};
		$ret->{'filename_ext'}  = '';
	}
	else {
		$ret->{'filename_core'} = join( '.', @temp );
	}
	return $ret;
}

sub __process_returned_form {
	my ( $self, $c ) = @_;
	my ( $dataset, @data, $str );
	## check the temp path and store that in the cookie
  #$c->session->{'path'} = undef unless ( $c->session->{'path'} =~m/\/tmp\/?/ );
	$c->session_path();    #unless ( defined $c->session->{'path'} );
	unless ( -d $c->session->{'path'} ) {
		mkdir( $c->session->{'path'} )
		  or Carp::confess( "I could not create the path '"
			  . $c->session->{'path'}
			  . "'\n$!\n" );
	}
	for my $field ( $c->req->uploads ) {

#		Carp::confess ( root->print_perl_var_def ( {'$field' =>  $field, 'all' => [$c->form->fields] } ) );
		if ( ref($field) eq "HASH" ) {
			foreach my $type ( keys %$field ) {    ## multiple file options
				$dataset->{$type} = [];
				foreach my $upload (
					map {
						if   ( ref($_) eq "ARRAY" ) { @$_ }
						else                        { $_ }
					} $field->{$type}
				  )
				{
					my $filename = $upload->basename;
					unless (
						$upload->copy_to( $c->session->{'path'} . "$filename" )
					  )
					{
						Carp::confess(
"I tried to upload the field named '$field->{'name'}' "
							  . "which should be a file, ("
							  . $c->session->{'path'}
							  . "/$filename) but I got no file object but ("
							  . $upload . ")!\n"
							  . "A frequent error is to not use the 'post' methood for the page (missing the line '$c->form->method('post');')\n"
						);
					}
					else {
						push(
							@{ $dataset->{$type} },
							root->filemap( $c->session->{'path'} . $filename )
						);
					}

				}
			}
		}
	}
	foreach my $field ( $c->form->fields ) {
		$str .= "$field; ";
		if ( defined( $field->{'type'} ) && $field->{'type'} eq "file" ) {
			unless ( defined $dataset->{$field} ) {

#			Carp::confess( "Internal file upload error - A frequent cause of this error is to not use the 'post' methood for the page (missing the line '$c->form->method('post');')\n" );
			}
			next;
		}
		elsif ( $field->{'multiple'} ) {
			@data = $c->form->field($field);
			$dataset->{$field} = [@data];
		}
		else {
			@data = $c->form->field($field);
			$dataset->{$field} = $data[0];
		}
	}
	unless ( keys %$dataset > 0 ) {
		## probably a re-read of the data?
		return $self->{'form_store'}
		  if ( ref( $self->{'form_store'} ) eq "HASH" );
		return $dataset;
	}
	$self->{'form_store'} = { map { $_ => $dataset->{$_} } keys %$dataset };
	return $dataset;
}

sub print_hashEntries {
	my ( $hash, $maxDepth, $topMessage ) = @_;
	my $string = $topMessage
	  || "DEBUG entries of the data structure $hash:\n";
	if ( $hash =~ m/ARRAY/ ) {
		my $i = 0;
		foreach my $value (@$hash) {
			$string .= printEntry( "List entry $i", $value, 1, $maxDepth );
			$i++;
		}
	}
	elsif ( $hash =~ m/HASH/ ) {
		my $key;
		foreach $key ( sort keys %$hash ) {
			$string .= printEntry( $key, $hash->{$key}, 1, $maxDepth );
		}
	}
	return $string;
}

sub printEntry {
	my ( $key, $value, $i, $maxDepth ) = @_;

	my $max    = 10;
	my $string = '';
	my ( $printableString, $maxStrLength );
	$maxStrLength = 50;

	if ( defined $value ) {
		for ( $a = $i ; $a > 0 ; $a-- ) {
			$string .= "\t";
		}
		$printableString = $value;
		if ( length($value) > $maxStrLength ) {
			$printableString = substr( $value, 0, $maxStrLength ) . " ...";
		}
		$string .= "$key\t$printableString\n";
	}
	else {
		for ( $a = $i ; $a > 0 ; $a-- ) {
			$string .= "\t";
		}
		$printableString = $key;
		if ( length($printableString) > $maxStrLength ) {
			$printableString = substr( $key, 0, $maxStrLength );
			$printableString = "$printableString ...";
		}
		$string .= "$printableString\n";
	}
	return $string if ( $maxDepth == $i );
	foreach $value ( $value, $key ) {
		if ( ref($value) eq "ARRAY" ) {
			for ( my $i = 0 ; $i < 20 ; $i++ ) {
				$string .= printEntry( @$value[$i], undef, $i + 1, $maxDepth );
			}
		}
		elsif ( $value =~ m/HASH/ ) {
			$max = 20;
			while ( my ( $key1, $value1 ) = each %$value ) {
				$string .= printEntry( $key1, $value1, $i + 1, $maxDepth );
				last if ( $max-- == 0 );
			}
		}
	}
	return $string;
}

sub _R_source {
	my ( $self, @files ) = @_;
	my $str = "";
	map { $str .= "source('$_')\n" } @files;
	return $str;
}

sub path {
	my ( $self, $c ) = @_;
	return $c->session_path();
}

sub options_to_HTML_table {
	my ( $self, $dataset ) = @_;
	my $ret   = "<tr><td>Variable Name</td>";
	my $other = "<tr><td>Value</td>";
	my $value;
	foreach my $key ( sort keys %$dataset ) {
		$ret   .= "<td>$key</td>";
		$other .= "<td> " . $self->check_value( $dataset->{$key} );
	}
	return "<table border='1px solid black' >$ret</tr>$other</tr></table>\n";
}

sub check_value {
	my ( $self, @values ) = @_;
	@values = @{ $values[0] } if ( ref( $values[0] ) eq "ARRAY" );
	return join(
		"; ",
		map {
			my $value = $_;
			if ( ref($value) eq "HASH" && defined $value->{'filename'} ) {
				$value = $value->{'filename'};
			}
			$value;
		  } @values
	);
}

sub slurp_webGL {
	my ( $self, $c, $file, $path ) = @_;
	$path ||= $c->session_path();
	if ( -f $path . "R.error" ) {
		open( IN, "<$path" . "R.error" );
		$c->stash->{'message'} .= join( "", <IN> );
		close(IN);
	}
	my ( $script, $use, @onload );
	$use = 0;
	return 0 unless ( -f "$path/webGL/index.html" );
	$script =
	    "<form action=''>\n"
	  . "<table border='0'>"
	  . "<tr><td>"
	  . "<input type='radio' name='plotSelector' value='2D'\n"
	  . "onClick=\"showElementByVisible('twoD');hideElementByDisplay('threeD');hideElementByDisplay('kernel');hideElementByDisplay('loadings')\">2 components\n</td><td>"
	  . "<input type='radio' name='plotSelector' value='3D' checked\n"
	  . "onClick=\"showElementByVisible('threeD');hideElementByDisplay('twoD');hideElementByDisplay('kernel');hideElementByDisplay('loadings')\">3 components (scatter)\n</td></tr><tr><td>"
	  . "<input type='radio' name='plotSelector' value='2D_loadings' \n"
	  . "onClick=\"showElementByVisible('loadings');hideElementByDisplay('threeD');hideElementByDisplay('twoD');hideElementByDisplay('kernel')\">2 components (loadings)\n</td><td>"
	  . "<input type='radio' name='plotSelector' value='kernel' \n"
	  . "onClick=\"showElementByVisible('kernel');hideElementByDisplay('twoD');hideElementByDisplay('threeD');hideElementByDisplay('loadings')\">3 components (density)\n</td></tr></table>"
	  . "</form>\n"
	  . "<span id='threeD' style='display:inline;'>\n<button onclick='capture3D(\"div\")'>To Scrapbook</button>\n<!-- START READ FROM FILE $path/webGL/index.html -->\n";
	my ($fileA, $fileB);
	
	($fileA, $onload[0]) = $c->model('java_splicer')->read_webGL( "$path/webGL/index.html" );
	$onload[0] = 'webGLStart();' unless ( defined  $onload[0]);
	if ( -f "$path/densityWebGL/index.html" ) {
		($fileB, $onload[1]) = $c->model('java_splicer')->read_webGL( "$path/densityWebGL/index.html" );
		$onload[1] = 'KwebGLStart();' unless ( defined  $onload[1]);
	}else {
		Carp::confess( "Seriouse problem: density wegGL was not produced!" );
	}
	my ( $full, $partA, $partB, $rgl_js);
	( $full, $partB, $rgl_js ) = $c->model('java_splicer')->drop_duplicates ( $fileA, $fileB );
	( $full, $partA, $rgl_js ) = $c->model('java_splicer')->drop_duplicates ( $fileB, $fileA );
	$rgl_js =~ 
	#$rgl_js =~ s/this.textureCanvas = document.createElement\("canvas"\);/this.textureCanvas = document.createElement\("canvas"\);\nthis.textureCanvas.getContext("experimental-webgl", {preserveDrawingBuffer: true})/;
#	open ( OUT , ">$path/densityWebGL/rgl.js" ) or die $!;
	#print OUT $rgl_js;
	#close ( OUT );
	$self->Script( $c, '<script type="text/javascript" src="'. $c->uri_for( '/scripts/rglClass.src.js' ).'"></script>');
	$self->Script( $c, '<script type="text/javascript" src="'. $c->uri_for( '/scripts/CanvasMatrix4.js' ).'"></script>');
	
	$script .= $partA
	."<!-- END READ FROM FILE $path/webGL/index.html -->\n"
	."</span><span id='kernel'  style='display:none'>\n<button onclick='capture3D(\"Kdiv\")'>To Scrapbook</button>\n<!-- START READ FROM FILE $path/densityWebGL/index.html-->\n"
	.$partB."<br><b>Known bug - Drag the white area above to make the plot appear</b>";

	$script .=
	    "</span><span id='twoD'  style='display:none'>\n"
	  . "<button onclick='capture2D(\"data\")'>To Scrapbook</button>\n"
	  . "<img id='data' src='"
	  . $c->uri_for( '/files/index' . $path . 'webGL/MDS_2D.png' )
	  . "' alt='2D image of the MDS results' width='400px'>\n"
	  . '<button type="submit" value="RemoveSamples" onclick="submitMasterForm(\'RemoveSamples\')">Remove selected samples (start from scratch to re-do)</button>'
	  . "\n"
	  . '<script>' . "\n"
	  . 'function submitMasterForm( v )' . "\n" . '{' . "\n"
	  . 'var x = document.getElementById("master");' . "\n"
	  . ' x._submit.value = v;' . "\n"
	  . ' x.submit(\'RemoveSamples\');' . "\n"
	  . 'document.getElementById("demo").innerHTML=x;' . "\n" . '}' . "\n"
	  . '</script>' . "\n";
	if ( -f $path . "loadings.png" ) {
		$script .=
		    "</span><span id='loadings'  style='display:none'>\n"
		  . "<button onclick='capture2D(\"data2\")'>To Scrapbook</button>\n"
		  . "<img id='data2' src='"
		  . $c->uri_for( '/files/index' . $path . 'loadings.png' )
		  . "' alt='2D gene loadings' width='400px'>\n";
	}
	if ( !( $script =~ m/webGLStart/ ) ) {
		## new version
		$script .= '<script type="text/javascript">'
		  . "\nwebGLStart = function(){rgl.start();}\n";
		if ( -f "$path/densityWebGL/index.html" ) {
			$script .= "KwebGLStart = function(){Krgl.start();}\n";
		}
		$script .= "</script>\n";
	}
	$c->stash->{'webGL'}           = $script;
#	$c->stash->{'body_extensions'} = 'onload="'.join('', @onload).'"';
	$c->stash->{'body_extensions'} = 'onload="webGLStart();KwebGLStart();"';

}

sub slurp_Heatmaps {
	my ( $self, $c, $path ) = @_;
	$path ||= $c->session_path();
	if ( -f $path . 'facs_Heatmap.png' ) {
		$c->stash->{'PCRHeatmap'} = join(
			"",
			$self->create_multi_image_scalable_canvas(
				$c,                              'heatmaps',
				'heatpic',                       'picture',
				'PCR_color_groups_Heatmap.png',  'PCR_Heatmap.png',
				'facs_color_groups_Heatmap.png', 'facs_Heatmap.png',
			)
		);
		$c->stash->{'HeatmapStatic'} = join(
			"",
			$self->create_selector_table_4_figures(
				$c,                 'heatmaps_s',
				'heatpic_s',        'picture_s',
				'PCR_Heatmap.png',  'PCR_color_groups_Heatmap.png',
				'facs_Heatmap.png', 'facs_color_groups_Heatmap.png',
			)
		);
	}
	else {
		$c->stash->{'PCRHeatmap'} = join(
			"",
			$self->create_multi_image_scalable_canvas(
				$c, 'heatmaps', 'heatpic', 'picture',
				'PCR_color_groups_Heatmap.png', 'PCR_Heatmap.png',

			)
		);
		$c->stash->{'HeatmapStatic'} = join(
			"",
			$self->create_selector_table_4_figures(
				$c,                'heatmaps_s',
				'heatpic_s',       'picture_s',
				'PCR_Heatmap.png', 'PCR_color_groups_Heatmap.png',

			)
		);
	}
	$self->Script( $c,
		    '<script type="text/javascript" src="'
		  . $c->uri_for('/scripts/jquery.min.js')
		  . '"></script>'
		  . '<script type="text/javascript" src="'
		  . $c->uri_for('/scripts/jquery.mousewheel.min.js') . '"'
		  . "></script>\n"
		  . '<script type="text/javascript" src="'
		  . $c->uri_for('/scripts/CanvasScale.js') . '"'
		  . "></script>\n" . "\n"
		  . "<script type='text/javascript'>\n \$(window).load ( function () {"
		  . "img_reset( 'picture_1' );"
		  . "register_mousewheelzoom('ScalableCanvas');} );</script>\n" );

}

sub Script {
	my ( $self, $c, $add ) = @_;
	$c->stash->{'script'} ||= '';
	if ( defined $add ) {
		foreach ( split( "\n", $add ) ) {
			my $check = $_;
			$check =~ s/\(/\\(/g;
			$check =~ s/\)/\\)/g;
			$check =~ s/\}/\\}/g;
			$check =~ s/\{/\\{/g;
			#warn "EnableFiles::Script:". $check."\n";
			$c->stash->{'script'} .= $_ . "\n"
			  unless ( $c->stash->{'script'} =~ m/$check/ );
		}
	}
	$c->stash->{'script'};
}

sub create_multi_image_scalable_canvas {

	my ( $self, $c, $obj_name, $view_name, $boxname, @figure_files ) = @_;

	my @return =
	  (     "<table border='0' cellspacing='0' cellpadding='0'>\n" 
		  . "<tr>\n"
		  . "<td width='100%'>" );
	$self->{'select_box'} = "<form id='$obj_name'><p><select\n"
	  . "name='$boxname' size='1' onChange='loadimage(\"$obj_name\", \"$boxname\" )'>\n";
	$self->{'select_options'} = [];
	my ( $default, $key, $map, $path, $id );
	$path = $self->path($c);
	$id   = 1;
	$default =
	    "<td width='100%'><p align='center'>"
	  . "<canvas id='ScalableCanvas' width=1000 height = 1000 draggable='true' ondragstart='drag(event)' > </canvas>"
	  . "</p>\n";

	foreach (@figure_files) {
		$map = $self->filemap($_);
		$key = $map->{'filename_core'};
		push( @{ $self->{'select_options'} },
			{ $boxname . "_" . $id => $key } );
		$default .=
		    "<img src='"
		  . $c->uri_for( '/files/index' . $path . "$_" )
		  . "' id='$boxname"
		  . "_$id' style='display:none'>\n";
		unless ( $self->{'select_box'} =~ m/option selected value/ ) {
			$self->{'select_box'} .=
			    "<option selected value='$boxname" . "_" 
			  . $id
			  . "'>$key</option>\n";
		}
		else {
			$self->{'select_box'} .=
			  "<option value='$boxname" . "_" . $id . "'>$key</option>\n";
		}

		$id++;
	}
	$default .= "</td>";
	$self->{'select_box'} .= "</select></p>\n" . "</form>\n";
	push( @return,
		$self->{'select_box'}, "</td>\n" . "</tr>\n" . "<tr>\n",
		$default, "</tr>\n" . "</table>\n" );
	return @return;
}

sub create_selector_table_4_figures {
	my ( $self, $c, $obj_name, $view_name, $boxname, @figure_files ) = @_;

	my @return =
	  (     "<table border='0' cellspacing='0' cellpadding='0'>\n" 
		  . "<tr>\n"
		  . "<td width='100%'>" );
	$self->{'select_box'} = "<form id='$obj_name'><p><select\n"
	  . "name='$boxname' size='1' onChange='showimage(\"$obj_name\", \"$view_name\", \"$boxname\" )'>\n";
	$self->{'select_options'} = [];
	my ( $default, $key, $map, $path );
	$path = $self->path($c);

	my $goi = {};
	if ( -f $path . "GOI.xls" ) {
		open( IN, "<" . $path . "GOI.xls" );
		my @line;
		while (<IN>) {
			$_ =~ s/"//g;
			chomp;
			@line = split( " ", $_ );
			$goi->{ $line[0] } = sprintf( ' %.1e', $line[1] )
			  if ( defined $line[1] );
		}
	}
	foreach (@figure_files) {
		$map = $self->filemap($_);
		$key = $map->{'filename_core'};
		$key .= $goi->{$key} if ( defined $goi->{$key} );
		push(
			@{ $self->{'select_options'} },
			{ $c->uri_for( '/files/index' . $path . "$_" ) => $key }
		);
		unless ( $self->{'select_box'} =~ m/option selected value/ ) {
			$default =
			    "<td width='100%'><p align='center'><img src='"
			  . $c->uri_for( '/files/index' . $path . "$_" )
			  . "' width='100%' id='$view_name'></p></td>\n";
			$self->{'select_box'} .=
			    "<option selected value='"
			  . $c->uri_for( '/files/index' . $path . "$_" )
			  . "'>$key</option>\n";
		}
		else {
			$self->{'select_box'} .=
			    "<option value='"
			  . $c->uri_for( '/files/index' . $path . "$_" )
			  . "'>$key</option>\n";
		}
	}
	my $d = $self->__process_returned_form($c);

	#Carp::confess ("\$exp = ".root->print_perl_var_def( $d ).";\n" );
	if ( defined $d->{$boxname} )
	{ ## the function has been used to create a figure selection form - show the selected figure again!
		my $tmp = "/static/images/Empty_selection.png";
		if ( ref( $d->{$boxname} ) eq "ARRAY" ) {
			$tmp = @{ $d->{$boxname} }[0]
			  if ( defined @{ $d->{$boxname} }[0] );
		}
		elsif ( $d->{$boxname} =~ m/.png$/ ) {
			$tmp = $d->{$boxname};
		}
		$default =
		    "<td width='100%'><p align='center'><img src='" 
		  . $tmp
		  . "' width='100%' id='$view_name'></td>\n";
	}
	$self->{'select_box'} .= "</select></p>\n" . "</form>\n";
	push( @return,
		$self->{'select_box'}, "</td>\n" . "</tr>\n" . "<tr>\n",
		$default, "</tr>\n" . "</table>\n" );
	return @return;
}

sub Additional_Script {
	return '';
}

sub figure_script_2D {
	my ($self) = @_;
	Carp::confess(
'not longer supported! use instead:\n<script type="text/javascript" src="/scripts/figures.js"></script>'
	);

}

1;
