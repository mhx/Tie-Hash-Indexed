################################################################################
#
# $Project: /Tie-Hash-Indexed $
# $Author: mhx $
# $Date: 2003/11/05 21:11:26 +0000 $
# $Revision: 4 $
# $Snapshot: /Tie-Hash-Indexed/0.03 $
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
use Config;

$MODULE = 'Tie::Hash::Indexed';

%FEATURES = (
  debug => {
             enabled => $Config{ccflags} =~ /-DDEBUGGING\b/ ? 1 : 0,
             e_flags => [qw( THI_DEBUGGING )],
             d_flags => [qw( NDEBUG )],
           },
);

@ARGV = map {
  my $myopt = 0;
  if( my($what, $feat) = /^(en|dis)able-(\S+)$/ ) {
    exists $FEATURES{$feat} or $feat = '$'.$feat;
    exists $FEATURES{$feat}
      or die "Invalid feature '$2'. Use one of [ @{[keys %FEATURES]} ].\n";
    $FEATURES{$feat}{enabled} = $what eq 'en';
    $myopt = 1;
  }
  elsif( /^help$/ ) {
    die <<ENDUSAGE;

USAGE: $^X Makefile.PL enable-feature disable-feature

  Available Features: @{[sort grep !/^\$/, keys %FEATURES]}

ENDUSAGE
  }
  $myopt ? () : $_
} @ARGV;

WriteMakefile(
  NAME           => $MODULE,
  VERSION_FROM   => 'lib/Tie/Hash/Indexed.pm',
  PREREQ_PM      => { 'Test' => 0 },
  ($] >= 5.005 ?
    (ABSTRACT    => 'Ordered hashes for Perl',
     AUTHOR      => 'Marcus Holland-Moritz <mhx@cpan.org>') : ()),
  INC            => '-I.',
  CONFIGURE      => \&configure,
);

#############################################################################

sub configure {
  for( keys %FEATURES ) {
    my $f = $FEATURES{$_};
    $f->{enabled} and print "Building with feature '$_'\n";
    push @DEFINE, @{$f->{enabled} ? $f->{e_flags} : $f->{d_flags} };
  }
  
  { 'DEFINE' => join(' ', map("-D$_", @DEFINE)) };
}

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

