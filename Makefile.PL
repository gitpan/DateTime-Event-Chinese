use strict;
use inc::Module::Install;

name('DateTime-Event-Chinese');
all_from('lib/DateTime/Event/Chinese.pm');

requires 'DateTime';
requires 'DateTime::Util::Astro' => '0.11';
requires 'DateTime::Event::Lunar' => '0.06';
requires 'DateTime::Event::SolarTerm' => '0.05';
requires 'Params::Validate';
requires 'Math::Round';

auto_install;
WriteAll;