#!/usr/local/bin/perl

use strict;

use warnings;
use feature qw(say);
use Test::More;

my @tests = ([1,2],[9,11],[99,101],[989,999],[999,1001],[10,11],[11,22],[12,22],
 [1990,1991],[1992,2002],[99011,99099],[97979,98089],[99099,99199],[99999,100001],
 [111222,112211]);
#@tests = map { chomp; [split] } <>;

is( next_palindrome(       $_->[0] ), $_->[1] ) foreach @tests;
is( next_palindrome_naive( $_->[0] ), $_->[1] ) foreach @tests;

done_testing();

use Benchmark qw{ cmpthese };
my @ranges = (
  [ 100_000, 1, 101 ],
  [ 50_000, 950, 1050 ],
  [ 20_000, 9950, 10050 ],
  [ 10_000, 99950, 100050 ],
  [ 5_000, 999950, 1000050 ],
  [ 1_000, 9999950, 10000050 ],
  [ 1_000, 99999950, 100000050 ],
);

foreach my $r (@ranges) {
  cmpthese($r->[0], {
    slow => sub { next_palindrome_naive($_) for $r->[1] .. $r->[2] },
    fast => sub { next_palindrome($_)       for $r->[1] .. $r->[2] },
  });
}

sub next_palindrome_naive {
  my ($n) = @_;
  1 until ++$n eq reverse $n;
  return $n
}

sub next_palindrome {
  my $p  = 1 + shift;
  my $x = substr $p, 0, (length $p)>>1;
  if( 1 & length $p ) {
    ## Odd length so we have three options...
    ## new number by reversing the first half of the number > $n so OK!
    ## middle digit is < 9 so just increment that
    ## o/w we will need to increment the first half and reverse it...
    ## if $x is 999 then the only time we could do the ++ to get
    ## a longer string is when $p is of the form 999.9.999, but
    ## then 999.9.999 > 999.9.998 and so we don't get this... so we
    ## are safe with this approach...
    my $y = substr $p, (length$p)>>1, 1;
    return $x.$y.reverse $x      if $p <= $x.$y.reverse $x;
    return $x.($y+1).reverse $x  if $y<9;
    return ++$x.'0'.reverse $x;
  }
  ## Even no of digits..
  ## If $n >= $x.reverse $x we incrememnt $x;
  ## The only time that this could lead to a longer number is when
  ## $x is 999 and is OK as $x.reverse $x will always be larger than
  ## $n....
  return $x.reverse $x  if $p <= $x.reverse $x;
  return ++$x.reverse $x;
}


