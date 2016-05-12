################################################################################
#
# Copyright (c) 2002-2016 Marcus Holland-Moritz. All rights reserved.
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#
################################################################################

use Test;

BEGIN { plan tests => 50 };

use Tie::Hash::Indexed;
ok(1);

my $h = Tie::Hash::Indexed->new(foo => 1, bar => 2, zoo => 3, baz => 4);

ok(join(',', $h->keys), 'foo,bar,zoo,baz');
ok($h->exists('foo'));
ok($h->has('bar'));
ok(!$h->has('xxx'));
ok(scalar $h->keys, 4);

$h->set('xxx', 5);
ok(join(',', $h->keys), 'foo,bar,zoo,baz,xxx');
ok($h->has('xxx'));
ok(scalar $h->keys, 5);

$h->set('foo', 6);
ok(join(',', $h->keys), 'foo,bar,zoo,baz,xxx');
ok($h->exists('foo'));
ok(scalar $h->keys, 5);

ok(join(',', $h->keys('xxx', 'bar')), 'xxx,bar');
ok(join(',', $h->values('xxx', 'bar')), '5,2');
ok(join(',', $h->as_list('xxx', 'bar')), 'xxx,5,bar,2');

# while (my($k,$v) = each %h) {
#   $key .= $k;
#   push @val, $v;
# }
# ok($key, 'foobarzoobazxxx');
# ok(join('|', @val), '6|2|3|4|5');

$val = $h->delete('bar');
ok($val, 2);
ok(join(',', $h->keys), 'foo,zoo,baz,xxx');
ok(join(',', $h->values), '6,3,4,5');
ok(scalar $h->keys, 4);
ok(!$h->exists('bar'));

$val = $h->delete('bar');
ok(not defined $val);

$val = $h->delete('nokey');
ok(not defined $val);

$h->clear;
ok(scalar $h->keys, 0);
ok(!$h->exists('zoo'));

$h->set("void", 0);

$h->clear->merge(foo => 1, bar => 2, zoo => 3, baz => 4);
ok(join(',', $h->as_list), "foo,1,bar,2,zoo,3,baz,4");
ok(scalar $h->keys, 4);

ok($h->merge(xxx => 5, bar => 6), 5);
ok(join(',', $h->as_list), "foo,1,bar,6,zoo,3,baz,4,xxx,5");
ok(scalar $h->keys, 5);

ok($h->assign(xxx => 5, bar => 6, zoo => 7), 3);
ok(join(',', $h->as_list), "xxx,5,bar,6,zoo,7");
ok(scalar $h->keys, 3);

ok($h->push(foo => 1, bar => 2), 4);
ok(join(',', $h->as_list), "xxx,5,zoo,7,foo,1,bar,2");
ok(scalar $h->keys, 4);

ok($h->unshift(zoo => 3, baz => 4), 5);
ok(join(',', $h->as_list), "zoo,3,baz,4,xxx,5,foo,1,bar,2");
ok(scalar $h->keys, 5);

ok(join(',', $h->pop), "bar,2");
ok(join(',', $h->items), "zoo,3,baz,4,xxx,5,foo,1");

ok(join(',', $h->shift), "zoo,3");
ok(join(',', $h->items), "baz,4,xxx,5,foo,1");

ok(join(',', scalar $h->pop), "1");
ok(join(',', $h->items), "baz,4,xxx,5");

ok(join(',', scalar $h->shift), "4");
ok(join(',', $h->items), "xxx,5");

ok(join(',', scalar $h->shift), "5");
ok(join(',', $h->items), "");

ok(scalar $h->shift, undef);
ok(join(',', $h->items), "");
