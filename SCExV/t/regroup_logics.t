#! /usr/bin/perl
use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'stefans_libs::flexible_data_structures::data_table' }

use FindBin;
my $plugin_path = "$FindBin::Bin";

my ( $value, @values, $exp );

my $data_table =
  data_table->new(
	{ 'filename' => $plugin_path . '/data/source_data/Sample_Colors.xls' } );

my $dataset = { 'g1' => "Group1Group2", 'g2' => 'Group3' };

$exp = [ sort	  qw(A9.P0 A12.P0 A10.P0 G9.P0 G8.P0 B10.P0 F11.P0 F9.P0 E11.P0 E9.P0 E8.P0 D11.P0 E7.P0 D10.P0 ref.P0 H11.P0 A7.P0 H10.P0 H8.P0 G12.P0
		B9.P0 G11.P0 B8.P0 B7.P0 B11.P0 F12.P0 C9.P0 C8.P0 C7.P0 C12.P0 F8.P0 C10.P0 E12.P0 D9.P0 D8.P0 D7.P0 D12.P0)
];

$value = { map { $_ => 1 } $dataset->{'g1'} =~ m/Group(\d+)/g };

$value = [sort @{$data_table->select_where(
					'Cluster',
					sub {
						my $v = shift;
						return 1 if ( $value->{$v} );
						return 0;
					}
				  )->GetAsArray('Samples')} ];

is_deeply( $value, $exp, 'Group merge 1 and 2 -> 2' );

$exp = [ sort  qw(A8.P0 H9.P0 A11.P0 G10.P0 B12.P0 G7.P0 F10.P0 C11.P0 F7.P0 E10.P0) ];

$value = { map { $_ => 1 } $dataset->{'g2'} =~ m/Group(\d+)/g };
$value = [sort @{$data_table->select_where(
					'Cluster',
					sub {
						my $v = shift;
						return 1 if ( $value->{$v} );
						return 0;
					}
				  )->GetAsArray('Samples')} ];
is_deeply( $value, $exp, 'Group merge 3 -> 2' );

#print "\$exp = ".root->print_perl_var_def(\@values ).";\n";

