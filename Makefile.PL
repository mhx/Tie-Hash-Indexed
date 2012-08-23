################################################################################
#
# $Project: /Tie-Hash-Indexed $
# $Author: mhx $
# $Date: 2003/11/03 21:25:27 +0000 $
# $Revision: 3 $
# $Snapshot: /Tie-Hash-Indexed/0.02 $
# $Source: /Makefile.PL $
#
################################################################################
# 
# Copyright (c) 2002-2003 Marcus Holland-Moritz. All rights reserved.
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
# 
################################################################################

use ExtUtils::MakeMaker;

$MODULE = 'Tie::Hash::Indexed';

WriteMakefile(
  NAME           => $MODULE,
  VERSION_FROM   => 'lib/Tie/Hash/Indexed.pm',
  PREREQ_PM      => { 'Test' => 0 },
  ($] >= 5.005 ?
    (ABSTRACT    => 'Ordered hashes for Perl',
     AUTHOR      => 'Marcus Holland-Moritz <mhx@cpan.org>') : ()),
  INC            => '-I.',
);

sub MY::metafile {
  package MY;
  my $self = shift;
  eval { require YAML; 1 }
      or return $self->SUPER::metafile_target(@_);

  my $node = new YAML::Node {};

  $node->{name}              = $self->{DISTNAME};
  $node->{version}           = $self->{VERSION};
  $node->{license}           = 'perl';
  $node->{distribution_type} = 'module';
  $node->{generated_by}      = "$::MODULE $0";

  my $dump = YAML::Dump( $node );

  $dump =~ s/^(.*)$/\t\$(NOECHO) \$(ECHO) "$1" >>META.yml/gm;
  $dump =~ s/>>META\.yml/>META.yml/;

  return "metafile:\n$dump";
}

