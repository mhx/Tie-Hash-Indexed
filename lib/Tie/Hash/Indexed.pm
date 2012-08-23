################################################################################
#
# $Project: /Tie-Hash-Indexed $
# $Author: mhx $
# $Date: 2003/11/03 21:17:47 +0000 $
# $Revision: 3 $
# $Snapshot: /Tie-Hash-Indexed/0.02 $
# $Source: /lib/Tie/Hash/Indexed.pm $
#
################################################################################
# 
# Copyright (c) 2002-2003 Marcus Holland-Moritz. All rights reserved.
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
# 
################################################################################

package Tie::Hash::Indexed;
use 5.004;
use DynaLoader;
use Tie::Hash;
use vars qw($VERSION @ISA);

@ISA = qw(DynaLoader Tie::Hash);
$VERSION = do { my @r = '$Snapshot: /Tie-Hash-Indexed/0.02 $' =~ /(\d+\.\d+(?:_\d+)?)/; @r ? $r[0] : '9.99' };

bootstrap Tie::Hash::Indexed $VERSION;

1;

__END__

=head1 NAME

Tie::Hash::Indexed - Ordered hashes for Perl

=head1 SYNOPSIS

  use Tie::Hash::Indexed;

  tie my %hash, 'Tie::Hash::Indexed';

  %hash = ( I => 1, n => 2, d => 3, e => 4 );
  $hash{x} = 5;

  print keys %hash, "\n";    # prints 'Index'
  print values %hash, "\n";  # prints '12345'

=head1 DESCRIPTION

Tie::Hash::Indexed is very similar to Tie::IxHash. However,
it is written completely in XS and usually about twice as
fast as Tie::IxHash. It's quite a lot faster when it comes
to clearing or deleting entries from large hashes.
Currently, only the plain tying mechanism is supported.

=head1 BUGS

If you find any bugs, Tie::Hash::Indexed doesn't seem to
build on your system or any of its tests fail, please use
the CPAN Request Tracker at L<http://rt.cpan.org/> to create
a ticket for the module. Alternatively, just send a mail
to E<lt>mhx@cpan.orgE<gt>.

=head1 TODO

If you're interested in what I currently plan to improve
(or fix), have a look at the F<TODO> file.

=head1 COPYRIGHT

Copyright (c) 2003 Marcus Holland-Moritz. All rights reserved.
This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

See L<perltie> and L<Tie::IxHash>.

=cut

