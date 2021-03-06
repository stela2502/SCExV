#! /usr/bin/perl -w

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

=head1 install.pl

Use this script to install the PCR analysis server to your computer.

To get further help use 'setup.pl -help' at the comman line.

=cut

use Getopt::Long;
use FindBin;
use Digest::MD5 qw(md5_hex);
use File::Copy;
use stefans_libs::install_helper::Patcher;

use strict;
use warnings;
my $plugin_path = "$FindBin::Bin";

my $VERSION = 'v1.0';

my ( $install_path,$help,$server_user,$debug, $nginx_web_path, @options, $web_root, $perlLibPath );

#my $root_path = "/var/www/html/HTPCR/";

Getopt::Long::GetOptions(
	"-install_path=s" => \$install_path,
	"-server_user=s" => \$server_user,
	"-web_root=s" => \$web_root,
	"-options=s{,}" => \@options,
	"-perlLibPath=s" => \$perlLibPath,
    "-nginx_web_path=s" => \$nginx_web_path,
	"-help"  => \$help,
	"-debug" => \$debug
);

my $warn  = '';
my $error = '';

unless ( defined $server_user ) {
	$error .= "the cmd line switch -server_user is undefined!\n";
}

unless ( defined $install_path ) {
	$error .= "the cmd line switch -install_path is undefined!\n";
}
unless ( defined $web_root ) {
	$web_root = "/var/www/html/";
}

if ($help) {
	print helpString();
	exit;
}

if ( $error =~ m/\w/ ) {
	print helpString($error);
	exit;
}

sub helpString {
	my $errorMessage = shift;
	$errorMessage = ' ' unless ( defined $errorMessage );
	return "
 $errorMessage
 command line switches for install.pl

   -install_path  :your server path
   -server_user   :the system user that needs to have access to all files
   -web_root      :the root of the web server - css and jscript files are installed there
                   default to '/var/www/html/'
   -options       :additional option for the SCExV server like
                   randomForest 1 ncore 4 
   -perlLibPath   :an optional perl lib path to run two separate SCExV server on one system
   -nginx_web_path:
                   which web path should the server have downstream of the main servername
                   
   -help   :print this help
   -debug  :verbose output
   

";
}


my $username = $ENV{LOGNAME} || $ENV{USER} || getpwuid($<);
unless ( $username eq "root" ){
	die"Please run this script as root to make all the steps work!\n";
}

## Change the HTpcrA.pm file to include the right config! Not the best way, but workable!
# patch the main function to include the new root path

my $patcher = stefans_libs::install_helper::Patcher->new($plugin_path."/../lib/HTpcrA.pm" );

system ( "cp $plugin_path/../lib/HTpcrA.pm $plugin_path/../lib/HTpcrA.save" );

my $OK = $patcher -> replace_string( "root =\\>.*,?\\n" , "root => '$install_path',\n" );
my $add = '';
if ( defined $perlLibPath) {
	my @tmp = split("/", "$perlLibPath");
	$add = pop( @tmp );
}

# replace the tmp file for the session::filemap plugin so that we can use multiple servers
$OK = $patcher -> replace_string( "'/tmp/session_develop'", "'/tmp/session_$add'");

# add all options

my $options ='';
for ( my $i = 0; $i < @options; $i += 2 ){
	$options .= "\t$options[$i] => '$options[$i+1]',\n" if ( defined $options[$i+1] );
}
unless ( $options =~ m/ncore/ ) {
	$options .= "\tncore => 1,\n";
}
unless ( $options =~ m/production/ ){
	$options .= "\tproduction => 1,\n";
}
$patcher -> replace_string("randomForest => 1,\\n\\s*ncore => \\d+,", "root => '$install_path',\n$options" );

$patcher -> write_file();

## almost done HTpcrA.pm



## change all tt2-, form- and java script files

my ($save, $save_home);

my $replace = $install_path;
my @files ;
if ( defined $nginx_web_path ){
	$nginx_web_path .= "/" unless ( $nginx_web_path =~ m/\/$/ );
	warn "I have the replace path '$nginx_web_path'\n";
	if ( $replace =~ m/\w/ ){
		## the server is installed downstream of the web root place
		## this kills my form files as they use fixed path
		foreach my $wpath ( "$plugin_path/../root/src/form/", "$plugin_path/../root/src/" ){
			opendir( DIR ,$wpath ) or die "could not open the path '$wpath'\n";
			@files = readdir(DIR);
			closedir(DIR);
			@files = map {$wpath.$_ } @files ;
			#print "And now I have the files". join(", ",@files )."\n";
			&patch_files( "'/help/", "'/$nginx_web_path"."help/", @files );
		}
		&patch_files( '/scrapbook/imageadd/', "/$nginx_web_path".'scrapbook/imageadd/', "$plugin_path/../root/scripts/scrapbook.js");
		&patch_files( '/scrapbook/screenshotadd', "/$nginx_web_path".'scrapbook/screenshotadd', "$plugin_path/../root/scripts/scrapbook.js");
	}
	
}


my $cmd = "cd $plugin_path/../ ; perl Makefile.PL";
if ( defined $perlLibPath ) {
	unless ( -d $perlLibPath ) {
		system( "mkdir -p $perlLibPath ");
	}
	$cmd .= " PREFIX=$perlLibPath INSTALLDIRS=site INSTALLSITELIB=$perlLibPath";
}

#&cleanup();
#die "This is the command to install the Perl source:\n$cmd\nand\nmv $plugin_path/../lib/HTpcrA.save $plugin_path/../lib/HTpcrA.pm\n";

system( $cmd );

system ( "make -C $plugin_path/../" );
system ( "make -C $plugin_path/../ install" );


mkdir( $install_path ) unless ( -p $install_path );
unless ( -d $install_path ) {
	die "Sorry - I could not create the path '$install_path'\n$!\n";
}

## create the PCGI file
open ( PSGI, ">$install_path/htpcra.psgi" ) or die "I could not create the PSGI file\n";

print PSGI "use strict;\n"."use warnings;\n";
if ( defined  $perlLibPath ){
	print PSGI "use lib '$perlLibPath';\n";
}
print PSGI "use HTpcrA;\n\n"."my \$app = HTpcrA->apply_default_middlewares(HTpcrA->psgi_app(\@_));\n"."\n\$app\n";

close ( PSGI );


system( "cp $plugin_path/htpcra_fastcgi.pl $install_path/htpcra_fastcgi.pl" );

my $patcher31 = stefans_libs::install_helper::Patcher->new("$install_path/htpcra_fastcgi.pl" );
$patcher31->replace_string( "use Catalyst::ScriptRunner;", "use Catalyst::ScriptRunner;\nuse lib '$perlLibPath';");
$patcher31-> write_file();

system( "cp $plugin_path/../SCExV.starman.initd $install_path/SCExV.starman.initd" );

my $patcher3 = stefans_libs::install_helper::Patcher->new("$install_path/SCExV.starman.initd" );
$patcher3->replace_string( "my \\\$app_home = '.*\\n", "my \$app_home = '$install_path';\n" );
$patcher3->replace_string( "name\\s+= '\\w+';", "name    = 'SCExV_$add';" );
$patcher3-> write_file();

system( "cp $plugin_path/../SCExV.fastcgi.initd $install_path/SCExV.fastcgi.initd" );

my $patcher4 = stefans_libs::install_helper::Patcher->new("$install_path/SCExV.fastcgi.initd" );
$patcher4->replace_string( "my \\\$app_home = '.*\\n", "my \$app_home = '$install_path';\n" );
$patcher4->replace_string( "name\\s+= '\\w+';", "name    = 'SCExV_$add';" );
$patcher4-> write_file();

## copy all files that are required for the server.

my $do_not_copy = { 'lib' => { 'site' => { 'piwik' => 1 }, 'tmp' => 1 } };
&copy_files($plugin_path."/../root/", $install_path, '', $do_not_copy);
mkdir ( $install_path."tmp/" ) unless ( -d $install_path."tmp/"  );
foreach ( 'css', 'rte', 'scripts', 'static', 'example_data' ){
	#die "I wold copy the files from '$plugin_path/../root/$_/' to '$web_root$_/'\n";
	&copy_files($plugin_path."/../root/$_/", $web_root."$_/" );
}

my $tmp = $install_path;
$tmp =~ s/$web_root/\//;
$tmp = $nginx_web_path;

unless ( -f $web_root."index.html" ){
	
	
	open ( OUT ,">".$web_root."index.html" ) or die "I could not create a simple index.html file in '$web_root'\n";
	print OUT "<!DOCTYPE html>
<html>
<head>
<meta charset='UTF-8'>
<title>Stem Cell Center Bioinformatics Group</title>
</head>
<body>
<h1>Stem Cell Center Bioinformatics Group</h1>

<p>Page under development!<p>

<p>Meanwhile you can access our <a href='$tmp' target='_blank'>HTpcrA tool (open beta)</a> </p>

</body>
</html>
	"
}



#### cron fixes the killing of the tmp files
unless ( -f "/usr/local/bin/CleanTemp.pl" ){
	#install the script
	system ( "cp $plugin_path../script/CleanTemp.pl /usr/local/bin/");
	system ( "chmod +x /usr/local/bin/CleanTemp.pl" );
}

mkdir ( "/etc/SCExV/" ) unless ( -d "/etx/SCExV/" );
my $f = "/etc/SCExV/tmpPaths.txt";
if  (-f $f  ) {
	open ( PATHS, "<$f" ) or die "Could not open the file '$f'\n$!\n";
	$tmp = {map {chomp; $_ => 1 } <PATHS>};
	close ( PATHS );
}else {
	system( "touch $f");
	$tmp = {};
}
unless ( $tmp ->{ $install_path."tmp/" } ) {
	open ( PATHS, ">>$f") or die $!;
	print PATHS $install_path."tmp/\n";
	close ( PATHS );
}

print "Please add to the root crontab the a ourly check of the tmp path using the /usr/local/bin/CleanTemp.pl script.\n"
."0\t*\t*\t*\t*\t/usr/local/bin/CleanTemp.pl\n";


unless ( -d "$install_path/tmp/"){
	mkdir ("$install_path/tmp/" );
	print "You need to allow the httpd to get access to the tem dir!\n"."execute on fedora or CentOS:\n"
	."chcon -R system_u:object_r:httpd_sys_rw_content_t:s0 $install_path/tmp/\n";
}

system( "chmod +x $install_path"."htpcra.psgi" );
system ( "chown -R $server_user:root $install_path");

#print "\nAll server files stored in '$install_path'\n\n"."If you want to set up a apache server\nyou should modify your apache2 configuration like that:\n".
#"<VirtualHost *:80>
#        ServerName localhost
#        ServerAdmin email\@host
#        HostnameLookups Off
#        UseCanonicalName Off
#        <Location $tmp>
#                SetHandler modperl
#                PerlResponseHandler Plack::Handler::Apache2
#                PerlSetVar psgi_app \"$install_path"."htpcra.psgi\"
#        </Location>
#</VirtualHost>
#\nPlease see this only as a hint on how to set up apache to work with this server!\n";

print "IN case the server does not work as expected (fedora):\n"
."chcon -R system_u:object_r:httpd_sys_content_t:s0 $install_path\n"
."chcon -R system_u:object_r:httpd_sys_rw_content_t:s0 $install_path/tmp/\n"
."chcon -R system_u:object_r:httpd_sys_rw_content_t:s0 $install_path/R_lib/\n"
;

open ( NGINX , ">$install_path/SCExV.nginx") or die "I could not create the nginx config file '$install_path/SCExV.nginx'\n$!\n";
print NGINX "server {
    listen       80;
    server_name  SCExV;
    location /SCExV/ {
        include fastcgi_params; # We'll discuss this later
        fastcgi_pass  unix:$install_path/SCExV.fastcgi.initd;
    }
}
";
close ( NGINX );


&cleanup();

sub cleanup {
	print "Cleaning up ...\n";
	
	system( "mv $plugin_path/../lib/HTpcrA.save $plugin_path/../lib/HTpcrA.pm");
	
	print "Done\n";
}

sub patch_files {
	my ( $pattern, $replace, @files ) = @_;
	my $OK;
	foreach my $file ( @files ) {
		next unless ( -f $file );
		my $patcher = stefans_libs::install_helper::Patcher->new( $file );
		$OK = 0;
		$OK = $patcher -> replace_string( $pattern, $replace );
		print "Replaced '$pattern' with '$replace' at $OK position(s) of file $file\n" if ( $OK > 0);
		$patcher -> write_file() if ( $OK );
	}
}

sub copy_files {
	my ( $source_path, $target_path, $subpath, $test_hash) = @_;
	$test_hash ||= {};
	$subpath = '' unless ( defined $subpath );
	my (@return);
	$source_path = "$source_path/" unless ( $source_path =~m/\/$/ );
	$target_path = "$target_path/" unless ( $target_path =~m/\/$/ );

	opendir( DIR, "$source_path/$subpath" )
	  or Carp::confess( "could not open path '$source_path/$subpath'\n$!\n");
	my @contents = readdir(DIR);
	closedir(DIR);
	foreach my $file (@contents) {
		next if ( $file =~ m/^\./);
		if ( defined $test_hash->{$file} ){
				unless( ref($test_hash->{$file}) eq "HASH") {
					next if ( -r $target_path . $subpath . "/$file" ) ;
				}
		}
		if ( -d $source_path . $subpath . "/$file" ) {
			push(
				@return,
				&copy_files(
					$source_path.$subpath, $target_path.$subpath,
					 "/$file", $test_hash->{$file}
				)
			);
		}
		else {
			unless ( -d $target_path . $subpath ) {
				system( "mkdir -p " . $target_path . $subpath );
			}
	#		print "I copy the file '".$source_path . $subpath . "/$file' to '$target_path" . "$subpath/$file'\n";
			copy(
				$source_path . $subpath . "/$file",
				$target_path . $subpath . "/$file"
			);
			push( @return, $subpath . "/$file" );
		}
	}
	return @return;
}

