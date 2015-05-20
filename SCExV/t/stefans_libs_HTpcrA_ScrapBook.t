#! /usr/bin/perl
use strict;
use warnings;
use Test::More tests => 5;
BEGIN { use_ok 'stefans_libs::HTpcrA::ScrapBook' }

use FindBin;
my $plugin_path = "$FindBin::Bin";

my ( $value, @values, $exp );
my $stefans_libs_HTpcrA_ScrapBook = stefans_libs::HTpcrA::ScrapBook->new();
is_deeply(
	ref($stefans_libs_HTpcrA_ScrapBook),
	'stefans_libs::HTpcrA::ScrapBook',
	'simple test of function stefans_libs::HTpcrA::ScrapBook -> new()'
);

#print "\$exp = ".root->print_perl_var_def($value ).";\n";
system( 'rm ' . $plugin_path . "/data/Outpath/Scrapbook.html" )
  if ( -f $plugin_path . "/data/Outpath/Scrapbook.html" );
$stefans_libs_HTpcrA_ScrapBook->init(
	$plugin_path . "/data/Outpath/Scrapbook.html" );
$stefans_libs_HTpcrA_ScrapBook->Add(
	'Some simple text - probably even a log entry');

ok( -f $plugin_path . "/data/Outpath/Scrapbook.html", "Scrapbook created" );

open( IN, "<" . $plugin_path . "/data/Outpath/Scrapbook.html" );
is_deeply( [<IN>],
	[ "\n", "<p>Some simple text - probably even a log entry</p>\n", "\n" ],
	"Text added" );
close(IN);

system( 'rm ' . $plugin_path . "/data/Outpath/Scrapbook.html" );
$stefans_libs_HTpcrA_ScrapBook->init(
	$plugin_path . "/data/Outpath/Scrapbook.html" );

$stefans_libs_HTpcrA_ScrapBook->Add( 'Some Caption text',
	$plugin_path . "/data/source_data/test.png" );

open( IN, "<" . $plugin_path . "/data/Outpath/Scrapbook.html" );
$exp = [
	"\n",
	"<figure>\n",
"	<img src=\"/home/slang/workspace/HTpcrA/t/data/source_data/test.png\" width=\"60%\">\n",
	"	<figcaption>Some Caption text</figcaption>\n",
	"</figure> \n",
	"\n"
];
is_deeply( [<IN>], $exp, "Figure added" );
close(IN);

#print "\$exp = ".root->print_perl_var_def($value ).";\n";
