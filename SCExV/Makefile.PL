#!/usr/bin/env perl
# IMPORTANT: if you delete this file your app will not work as
# expected.  You have been warned.
use inc::Module::Install;
use Module::Install::Catalyst; # Complain loudly if you don't have
                               # Catalyst::Devel installed or haven't said
                               # 'make dist' to create a standalone tarball.

name 'HTpcrA';
all_from 'lib/HTpcrA.pm';

requires 'Params::Validate'; ## required for Catalyst::Runtime
requires 'Catalyst::Runtime' => '5.90019';
#requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Plugin::ErrorCatcher';
requires 'Catalyst::Action::RenderView';
requires 'Moose';

## the autoclean has a missing dependancy:
requires 'Module::Implementation';
requires 'Moose';
requires 'Moo';
requires 'namespace::autoclean';

#requires 'Config::General'; # This should reflect the config file format you've chosen
                 # See Catalyst::Plugin::ConfigLoader for supported formats
requires 'Daemon::Control';
#requires 'Catalyst::Plugin::RequireSSL';
requires 'Catalyst::Plugin::Session';
requires 'Catalyst::Plugin::Session::State::Cookie';
requires 'Catalyst::Plugin::Session::Store::FastMmap';
requires 'HTML::Template';
requires 'Catalyst::Model::Factory::PerRequest';
requires 'Stefans_Libs_Essentials';
requires 'Sys::Info';
requires 'Catalyst/Plugin/FormBuilder';
requires 'Catalyst::View::TT';
#requires 'Stefans_Lib_Essentials' => '1.01';

requires_external_bin('dos2unix');

test_requires 'Test::More' => '0.88';
#test_requires 'jQuery::File::Upload';

catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
