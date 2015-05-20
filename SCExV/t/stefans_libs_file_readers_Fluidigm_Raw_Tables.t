#! /usr/bin/perl
use strict;
use warnings;
use Test::More tests => 8;
BEGIN { use_ok 'stefans_libs::file_readers::PCR_Raw_Tables' }
use stefans_libs::root;

use FindBin;
my $plugin_path = "$FindBin::Bin";

my ( $test_object, $value, $exp, @values );
$test_object = stefans_libs::file_readers::PCR_Raw_Tables->new();
is_deeply( ref($test_object), 'stefans_libs::file_readers::PCR_Raw_Tables',
'simple test of function stefans_libs_file_readers_PCR_Raw_Tables -> new()'
);

#$value = $test_object->AddDataset(
#	{
#		'ID'                => 0,
#		'Sample-Name'       => 1,
#		'Sample-Type'       => 2,
#		'Sample-rConc'      => 3,
#		'FAM-MGB-Name'      => 4,
#		'FAM-MGB-Type'      => 5,
#		'FAM-MGB-Reference' => 6,
#		'Ct-Value'          => 7,
#		'Ct-Quality'        => 8,
#		'Ct-Call'           => 9,
#		'Threshold'         => 10,
#		'Value'             => 11,
#		'Quality'           => 12,
#		'Call'              => 13,
#	}
#);
#is_deeply( $value, 1, "we could add a sample dataset" );
print "$plugin_path/data/PCR_dataset.csv\n";
$test_object = stefans_libs::file_readers::PCR_Raw_Tables->new(
	{ 'filename' => "$plugin_path/data/PCR_dataset.csv" } );
is_deeply(
	@{ $test_object->{'data'} }[0],
	[
		'S48-A01',            'sc_42',
		'Unknown',            '1',
		'control',            'Reference',
		'',                   '13.9974541306985',
		'0.96',               'Pass',
		'0.0212016009526505', '0',
		'0.96',               'Pass' . "\n"
	],
	'First data line'
);
is_deeply(
	@{ $test_object->{'data'} }[ @{ $test_object->{'data'} } - 1 ],
	[
		'S22-A48',            'sc_16',
		'Unknown',            '1',
		'control',            'Reference',
		'',                   '12.462520264306',
		'0.32',               'Fail',
		'0.0212016009526505', '-2.39405885439419',
		'0.32',               'Fail' . "\n"
	],
	'last data line'
);

#print "\$exp = ".root->print_perl_var_def(  $test_object->{'data_table'}->GetAsHash('Sample-Name', 'Ccnf1') ).";\n";
$exp = {
  'sc_35' => '14.524747792757', #checked
  'sc_42' => '34.2127802540967', #checked
  'sc_13' => '39', #checked
  'sc_28' => '38.0502030946345', #checked
  'sc_36' => '39',
  'sc_37' => '39',
  'sc_11' => '39',
  'sc_9' => '39',
  'sc_23' => '39',
  'sc_31' => '39',
  'sc_6' => '39',
  'sc_15' => '16.8815043776235', #checked
  'sc_34' => '38.2028723238047', #checked
  'sc_5' => '39',
  'sc_26' => '39',
  'sc_25' => '39',
  'sc_20' => '39',
  'sc_21' => '39',
  'sc_4' => '39',
  'sc_39' => '39',
  'sc_18' => '39',
  'sc_10' => '39',
  'sc_24' => '39',
  'sc_17' => '39',
  'sc_27' => '15.7126193025715', #checked
  'sc_38' => '39',
  'sc_16' => '39',
  'sc_3' => '39',
  'sc_32' => '39',
  'sc_2' => '39',
  'sc_30' => '39', #checked
  'sc_41' => '39', #checked
  'sc_14' => '39',
  'sc_29' => '39',
  'sc_33' => '39',
  'sc_19' => '39',
  'sc_8' => '38.1982093497599', #checked
  'sc_7' => '39',
  'sc_12' => '39',
  'sc_22' => '39',
  'sc_40' => '39',
  'sc_1' => '39'
};

is_deeply( $test_object->{'data_table'}->GetAsHash('Sample-Name', 'Ccnf1') , $exp, 'gene Ccnf1' );

#print "\$exp = ".root->print_perl_var_def( $test_object->{'data_table'}->GetAsHash('Sample-Name', 'Hoxa5')).";\n";
$exp = {
  'sc_24' => '16.4636565091031',
  'sc_23' => '39',
  'sc_4' => '39',
  'sc_25' => '39',
  'sc_6' => '39',
  'sc_13' => '39',
  'sc_22' => '39',
  'sc_38' => '39',
  'sc_30' => '16.730507902195',
  'sc_2' => '38.0964551718312',
  'sc_14' => '27.9415409497232',
  'sc_18' => '39',
  'sc_12' => '39',
  'sc_27' => '39',
  'sc_21' => '39',
  'sc_17' => '39',
  'sc_42' => '39',
  'sc_37' => '39',
  'sc_33' => '39',
  'sc_28' => '39',
  'sc_11' => '39',
  'sc_41' => '39',
  'sc_34' => '39',
  'sc_5' => '39',
  'sc_36' => '39',
  'sc_39' => '39',
  'sc_16' => '32.4874113628084',
  'sc_29' => '39',
  'sc_32' => '39',
  'sc_1' => '39',
  'sc_20' => '39',
  'sc_15' => '39',
  'sc_8' => '39',
  'sc_19' => '39',
  'sc_3' => '39',
  'sc_7' => '39',
  'sc_40' => '39',
  'sc_31' => '39',
  'sc_9' => '39',
  'sc_35' => '35.7445526351641',
  'sc_26' => '39',
  'sc_10' => '39'
};
is_deeply( $test_object->{'data_table'}->GetAsHash('Sample-Name', 'Hoxa5') , $exp, 'gene Hoxa5' );

$test_object = stefans_libs::file_readers::PCR_Raw_Tables->new();

$test_object->Sample_Postfix('P1');
$test_object->read_file("$plugin_path/data/PCR_dataset.csv");
$exp = [
	'sc_42P1', 'sc_41P1', 'sc_40P1', 'sc_39P1', 'sc_38P1', 'sc_37P1',
	'sc_36P1', 'sc_3P1',  'sc_35P1', 'sc_2P1',  'sc_34P1', 'sc_1P1',
	'sc_33P1', 'sc_6P1',  'sc_32P1', 'sc_5P1',  'sc_31P1', 'sc_4P1',
	'sc_30P1', 'sc_9P1',  'sc_29P1', 'sc_8P1',  'sc_28P1', 'sc_7P1',
	'sc_27P1', 'sc_12P1', 'sc_26P1', 'sc_11P1', 'sc_25P1', 'sc_10P1',
	'sc_24P1', 'sc_15P1', 'sc_23P1', 'sc_14P1', 'sc_22P1', 'sc_13P1',
	'sc_21P1', 'sc_18P1', 'sc_20P1', 'sc_17P1', 'sc_19P1', 'sc_16P1'
];

#print "\$exp = ".root->print_perl_var_def( $test_object -> {'data_table'}->GetAsArray('Sample-Name') ).";\n";
is_deeply( $test_object->{'data_table'}->GetAsArray('Sample-Name'),
	$exp, 'Samples using a postfix' );
#print "\$exp = ".root->print_perl_var_def( $test_object -> {'data_table'}->{'header'} ).";\n";
$exp = [ 'Sample-Name', 'Bmi1', 'Byglycan', 'Cbx4', 'Ccna2', 'Ccnb2', 'Ccnd1', 'Ccne1', 'Ccnf1', 'Ccng1', 'Cd150', 'Cd34', 'Cd48', 'Cd9', 'Cebpa', 'Cited2', 'Ebf1', 'Epor', 'Esam1', 'Flt3', 'Gata1', 'Gata2', 'Gfi1', 'Hes1', 'Hoxa5', 'Ikzf1', 'Il7r', 'Lck', 'Mpl', 'Mpo', 'Pbx1', 'Procr', 'Rag1', 'Rbl1', 'Rbl2', 'Runx1', 'S100a6', 'Tal1', 'Tie1', 'control', 'control.1', 'control.2', 'ki67', 'p16', 'p18', 'p19', 'p21', 'p27', 'p57' ];
is_deeply( $test_object->{'data_table'}->{'header'},
	$exp, 'The orig header' );
	
## now troubleshoot some of the controler functions....
#$test_object = stefans_libs::file_readers::PCR_Raw_Tables->new( {'filename' => "$plugin_path/data/compr.PCR_dataset.cvs" });
#print join(" ", @$exp)."\n".join(" ",@{$test_object->{'data_table'}->{'header'}})."\n";
#is_deeply( $test_object->{'data_table'}->{'header'},
#	$exp, 'The compromised header' );


## A handy help if you do not know what you should expect
#print "$exp = ".root->print_perl_var_def($value ).";\n";
