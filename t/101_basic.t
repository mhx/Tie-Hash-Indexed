################################################################################
#
# $Project: /Tie-Hash-Indexed $
# $Author: mhx $
# $Date: 2003/11/02 14:12:02 +0000 $
# $Revision: 3 $
# $Snapshot: /Tie-Hash-Indexed/0.03 $
# $Source: /t/101_basic.t $
#
################################################################################
# 
# Copyright (c) 2002-2003 Marcus Holland-Moritz. All rights reserved.
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
# 
################################################################################

use Test;

BEGIN { plan tests => 26 };

use Tie::Hash::Indexed;
ok(1);

tie %h, 'Tie::Hash::Indexed';
ok(1);

%h = (foo => 1, bar => 2, zoo => 3, baz => 4);
ok( join(',', keys %h), 'foo,bar,zoo,baz' );
ok( exists $h{foo} );
ok( exists $h{bar} );
ok( !exists $h{xxx} );

$h{xxx} = 5;
ok( join(',', keys %h), 'foo,bar,zoo,baz,xxx' );
ok( exists $h{xxx} );

$h{foo} = 6;
ok( join(',', keys %h), 'foo,bar,zoo,baz,xxx' );
ok( exists $h{foo} );

while( my($k,$v) = each %h ) {
  $key .= $k;
  $val += $v;
}
ok( $key, 'foobarzoobazxxx' );
ok( $val, 20 );

$val = delete $h{bar};
ok( $val, 2 );
ok( join(',', keys %h), 'foo,zoo,baz,xxx' );
ok( join(',', values %h), '6,3,4,5' );
ok( scalar keys %h, 4 );
ok( !exists $h{bar} );

$val = delete $h{bar};
ok( not defined $val );

$val = delete $h{nokey};
ok( not defined $val );

%h = ();
ok( scalar keys %h, 0 );
ok( !exists $h{zoo} );

%h = (foo => 1, bar => 2, zoo => 3, baz => 4);
ok( join(',', %h), "foo,1,bar,2,zoo,3,baz,4" );
ok( scalar keys %h, 4 );

for( $h{foo} ) { $_ = 42 }
ok( $h{foo}, 42 );

untie %h;
ok( scalar keys %h, 0 );
ok( join(',', %h), '' );

