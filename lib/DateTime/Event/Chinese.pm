package DateTime::Event::Chinese;
use strict;
use vars qw($VERSION);
BEGIN
{
    $VERSION = '0.02';
}
use DateTime::Event::Lunar;
use DateTime::Event::SolarTerm qw(WINTER_SOLSTICE);
use DateTime::Util::Astro::Moon qw(MEAN_SYNODIC_MONTH);
use DateTime::Util::Calc qw(moment truncate_to_midday);
use Math::Round qw(round);
use Params::Validate;

my %BasicValidate = ( datetime => { isa => 'DateTime' } );

sub _new {
    my $class = shift;
    return bless {}, $class;
}

# [1] p.253
sub new_year_for_sui
{
    my $self = shift;
    my %args = Params::Validate::validate(@_, \%BasicValidate);
    my $dt   = $args{datetime}->clone->truncate(to => 'day')->set(hour => 12);

    my $s1 = DateTime::Event::SolarTerm->prev_term_at(
        datetime => $dt, longitude => WINTER_SOLSTICE);
    my $s2 = DateTime::Event::SolarTerm->prev_term_at(
        datetime => $dt + DateTime::Duration->new(days => 370),
        longitude => WINTER_SOLSTICE);

    my $m12 = DateTime::Event::Lunar->new_moon_after(
        datetime => $s1 + DateTime::Duration->new(days => 1));
    my $m13 = DateTime::Event::Lunar->new_moon_after(
        datetime => $m12 + DateTime::Duration->new(days => 1));
    my $next_m11 = DateTime::Event::Lunar->new_moon_before(
        datetime => $s2 + DateTime::Duration->new(days => 1));

    my $rv;
    if (round((moment($next_m11) - moment($m12)) / MEAN_SYNODIC_MONTH) == 12 &&
        (DateTime::Event::SolarTerm->no_major_term_on(datetime => $m12) or
         DateTime::Event::SolarTerm->no_major_term_on(datetime => $m13))) {

        $rv = DateTime::Event::Lunar->new_moon_after(
            datetime => $m13,
            on_or_after => 1);
    } else {
        $rv = $m13;
    }

    truncate_to_midday($rv);
    return $rv;
}

sub new_year
{
    my $class = shift;
    my $self  = $class->_new();
    return DateTime::Set->from_recurrence(
        next     => sub { $self->new_year_after(datetime => $_[0]) },
        previous => sub { $self->new_year_before(datetime => $_[0]) }
    );
}

# [1] p.253
sub new_year_before
{
    my $self = shift;
    my %args = Params::Validate::validate(@_, \%BasicValidate);
    my $dt   = $args{datetime}->clone->truncate(to => 'day')->set(hour => 12);

    my $new_year = $self->new_year_for_sui(datetime => $dt);
    my $rv;
    if ($dt > $new_year) {
        $rv = $new_year;
    } else {
        $rv = $self->new_year_for_sui(
            datetime => $dt - DateTime::Duration->new(days => 180));
    }
    return $rv;
}

# [1] p.260
sub new_year_for_gregorian_year
{
    my $self = shift;
    my %args = Params::Validate::validate(@_, \%BasicValidate);
    return $self->new_year_before(datetime => DateTime->new(
        year => $args{datetime}->year, month => 7, day => 1, time_zone => $args{datetime}->time_zone));
}

BEGIN
{
    if (eval { require Memoize } && !$@) {
        Memoize::memoize('new_year_for_gregorian_year', NORMALIZER => sub {
            my $self = shift;
            my %args = Params::Validate::validate(@_, \%BasicValidate);

            $args{datetime}->year;
        });
    }
}

# This one didn't exist in [1]. Basically, it just tries to get the
# chinese new year in the given year, and if that is before the given
# date, we get next year's.
sub new_year_after
{
    my $self = shift;
    my %args = Params::Validate::validate(@_, \%BasicValidate);
    my $dt   = $args{datetime}->clone->truncate(to => 'day')->set(hour => 12);

    my $new_year_this_gregorian_year = $self->new_year_for_gregorian_year(
        datetime => $dt);
    my $rv;
    if ($new_year_this_gregorian_year > $dt) {
        $rv = $new_year_this_gregorian_year;
    } else {
        $rv = $self->new_year_before(datetime => DateTime->new(
            year => $dt->year + 1, month => 7, day => 1,
            time_zone => $dt->time_zone));
    }
    return $rv;
}

1;

__END__

=head1 NAME

DateTime::Event::Chinese - DateTime Extension for Calculating Important Chinese Dates

=head1 SYNOPSIS

  use DateTime::Event::Chinese;
  my $new_moon = DateTime::Event::Chinese->new_year();

  my $dt0  = DateTime->new(...);
  my $next_new_year = $new_year->next($dt0);
  my $prev_new_year = $new_year->previous($dt0);

  my $dt1  = DateTime->new(...);
  my $dt2  = DateTime->new(...);
  my $span = DateTime::Span->new(start => $dt1, end => $dt2);

  my $set  = $new_year->intersection($span);
  my $iter = $set->iterator();

  while (my $dt = $iter->next) {
    print $dt->datetime, "\n";
  }

  my $new_year = DateTime::Event::Chinese->new_year_for_sui(dateitme => $dt);
  my $new_year = DateTime::Event::Chinese->new_year_for_gregorian_year(
    datetime => $dt);
  my $new_year = DateTime::Event::Chinese->new_year_after(datetime => $dt);
  my $new_year = DateTime::Event::Chinese->new_year_before(datetime => $dt);

=head1 DESCRIPTION

This modules implements the algorithm described in "Calendrical Calculations"
to compute some important Chinese dates, such as date of new year and
other holidays (Currently only new years can be calculated).

=head1 FUNCTIONS

=head2 DateTime::Event::Chinese-E<gt>new_year_for_sui(%args)

Returns the DateTime object representing the Chinese New Year for the
"sui" (the period between two winter solstices) of the given date.

  my $dt = DateTime::Event::Chinese->new_year_for_sui(
    datetime => $dt0
  );

=head2 DateTime::Event::Chinese-E<gt>new_year_for_greogrian_year(%args)

Returns the DateTime object representing the Chinese New Year for the
given gregorian year.

  my $dt = DateTime::Event::Chinese->new_year_for_sui(
    datetime => $dt0
  );

=head2 DateTime::Event::Chinese-E<gt>new_year_after(%args)

Returns a DateTime object representing the next Chinese New Year
relative to the given datetime argument.

  my $next_new_year = DateTime::Event::Lunar->new_year_after(datetime => $dt0);

This is the function that is internally used by new_year()-E<gt>next().

=head2 DateTime::Event::Chinese-E<gt>new_year_before(%args)

Returns a DateTime object representing the previous Chinese New Year
relative to the given datetime argument.

  my $prev_new_year = DateTime::Event::Lunar->new_year_beore(datetime => $dt0);

This is the function that is internally used by new_year()-E<gt>previous().

=head1 AUTHOR

Daisuke Maki E<lt>daisuke@cpan.orgE<gt>

=head1 REFERENCES

  [1] Edward M. Reingold, Nachum Dershowitz
      "Calendrical Calculations (Millenium Edition)", 2nd ed.
       Cambridge University Press, Cambridge, UK 2002

=head1 SEE ALSO

L<DateTime>
L<DateTime::Set>
L<DateTime::Span>
L<DateTime::Event::Lunar>
L<DateTime::Event::SolarTerm>

=cut
