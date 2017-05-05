#!/usr/bin/perl

use File::Spec;
use FindBin;
my $plugin_path = "$FindBin::Bin";

print $plugin_path."\n";

#my @curdir = File::Spec->splitdir($plugin_path);
#pop(@curdir);
#pop(@curdir);

print $plugin_path."/../root/\n";
