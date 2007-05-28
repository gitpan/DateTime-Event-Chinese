#!perl
use strict;
use Test::More;
use DateTime;

my @new_years;
BEGIN
{
    @new_years = map {
        my %hash;
        @hash{qw(year month day hour time_zone)} = (@$_, 12, 'Asia/Shanghai');
        DateTime->new(%hash);
    } (
        [ 1999, 2, 16 ],
        [ 2000, 2,  5 ],
        [ 2001, 1, 24 ],
        [ 2002, 2, 12 ],
        [ 2003, 2,  1 ],
        [ 2004, 1, 22 ],
        [ 2005, 2,  9 ],
        [ 2006, 1, 29 ],
        [ 2007, 2, 18 ],
    );

    plan tests => 2 * scalar(@new_years) + 1;

    print STDERR 
        "\n*** This test will take a long time, please be patient ***\n",
        "*** Starting on ", scalar(localtime), "\n";
    use_ok("DateTime::Event::Chinese");
}

foreach my $dt (@new_years) {
    my $dt0 = $dt - DateTime::Duration->new(days => int(rand(180)) + 1);
    my $ny  = DateTime::Event::Chinese->new_year_after(datetime => $dt0);

    ok($dt->compare($ny) == 0) or
        diag( "Expected " . $dt->datetime . ", but got " . $ny->datetime);
}

my $start = $new_years[0] + DateTime::Duration->new(days => -10);
my $end   = $new_years[$#new_years] + DateTime::Duration->new(days => 10);

my $ny   = DateTime::Event::Chinese->new_year();
my $dt   = $ny->next($start);
my $idx  = 0;
while($dt < $end) {
    ok($dt->compare($new_years[$idx++]) == 0);
    $dt = $ny->next($dt);
}
