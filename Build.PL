#!perl
# $Id$
#
# Daisuke Maki <dmaki@cpan.org>
# All rights reserved.

use strict;
use Module::Build;

my $build = Module::Build->new(
	module_name => 'DateTime::Event::Chinese',
	dist_name => 'DateTime-Event-Chinese',
	license => 'perl',
	requires => {
		'DateTime' => 0,
		'DateTime::Set' => 0,
		'DateTime::Event::Lunar' => '>= 0.04',
		'DateTime::Event::SolarTerm' => 0,
		'Params::Validate' => 0,
	},
    create_makefile_pl => 'traditional'
);
$build->create_build_script;
