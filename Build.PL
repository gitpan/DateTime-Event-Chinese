use strict;
use Module::Build;

my $build = Module::Build->new(
	module_name => 'DateTime::Event::Chinese',
	dist_name => 'DateTime-Event-Chinese',
	license => 'perl',
	requires => {
		'DateTime' => 0,
		'DateTime::Set' => 0,
		'DateTime::Event::Lunar' => 0,
		'DateTime::Event::SolarTerm' => 0,
		'Params::Validate' => 0,
	},
	sign => 1,
	create_readme => 1,
    create_makefile_pl => 'passthrough'
);
$build->create_build_script;
