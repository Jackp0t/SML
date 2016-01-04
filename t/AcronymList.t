#!/usr/bin/perl

use lib "../lib";
use Test::More tests => 15;

use SML;
use SML::Definition;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

# set sml.Library logger to WARN
my $logger_library = Log::Log4perl::get_logger('sml.Library');
$logger_library->level('WARN');

# set sml.AcronymList logger to ERROR
my $logger_aclist = Log::Log4perl::get_logger('sml.AcronymList');
$logger_aclist->level('ERROR');

use Test::Log4perl;

use SML::TestData;

#---------------------------------------------------------------------
# Test Data
#---------------------------------------------------------------------

my $td  = SML::TestData->new();
my $tcl = $td->get_acronym_list_test_case_list;

#---------------------------------------------------------------------
# Can use module?
#---------------------------------------------------------------------

BEGIN {
  use SML::AcronymList;
  use_ok( 'SML::AcronymList' );
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

my $obj = SML::AcronymList->new;
isa_ok( $obj, 'SML::AcronymList' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   # SML::AcronymList public methods
   'add_entry',
   'has_entry',
   'get_entry',
   'get_entry_list',
  );

can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Returns expected values?
#---------------------------------------------------------------------

foreach my $tc (@{$tcl})
  {
    add_entry_ok($tc)       if defined $tc->{expected}{add_entry};
    has_entry_ok($tc)       if defined $tc->{expected}{has_entry};
    get_entry_ok($tc)       if defined $tc->{expected}{get_entry};
    error_add_entry_ok($tc) if defined $tc->{expected}{error}{add_entry};
  }

get_entry_list_ok();

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

foreach my $tc (@{$tcl})
  {
    warn_get_entry_ok($tc)  if defined $tc->{expected}{warning}{get_entry};
  }

######################################################################

sub add_entry_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname       = $tc->{name};
  my $definition   = $tc->{definition};
  my $acronym_list = SML::AcronymList->new;
  my $expected     = $tc->{expected}{add_entry};

  # act
  my $result = $acronym_list->add_entry($definition);

  # assert
  is($result,$expected,"$tcname add_entry $result");
}

######################################################################

sub has_entry_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname       = $tc->{name};
  my $definition   = $tc->{definition};
  my $acronym      = $tc->{acronym};
  my $namespace    = $tc->{namespace};
  my $acronym_list = SML::AcronymList->new;
  my $expected     = $tc->{expected}{has_entry};

  $acronym_list->add_entry($definition);

  # act
  my $result = $acronym_list->has_entry($acronym,$namespace);

  # assert
  is($result,$expected,"$tcname has_entry $result");
}

######################################################################

sub get_entry_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname       = $tc->{name};
  my $definition   = $tc->{definition};
  my $acronym      = $tc->{acronym};
  my $namespace    = $tc->{namespace};
  my $acronym_list = SML::AcronymList->new;
  my $expected     = $tc->{expected}{get_entry};

  $acronym_list->add_entry($definition);

  # act
  my $result = ref $acronym_list->get_entry($acronym,$namespace);

  # assert
  is($result,$expected,"$tcname get_entry $result");
}

######################################################################

sub error_add_entry_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname       = $tc->{name};
  my $definition   = $tc->{definition};
  my $acronym_list = SML::AcronymList->new;
  my $expected     = $tc->{expected}{error}{add_entry};
  my $t1logger     = Test::Log4perl->get_logger('sml.AcronymList');

  Test::Log4perl->start( ignore_priority => "warn" );
  $t1logger->error(qr/$expected/);

  # act
  $acronym_list->add_entry($definition);

  # assert
  Test::Log4perl->end("$tcname $expected");
}

######################################################################

sub warn_get_entry_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname       = $tc->{name};
  my $acronym      = $tc->{acronym};
  my $namespace    = $tc->{namespace};
  my $acronym_list = SML::AcronymList->new;
  my $expected     = $tc->{expected}{warning}{get_entry};
  my $t1logger     = Test::Log4perl->get_logger('sml.AcronymList');

  Test::Log4perl->start( ignore_priority => "info" );
  $t1logger->warn(qr/$expected/);

  # act
  my $result = $acronym_list->get_entry($acronym,$namespace);

  # assert
  Test::Log4perl->end("$tcname $expected");
}

######################################################################

sub get_entry_list_ok {

  # arrange
  my $expected = 'ARRAY';
  my $al       = SML::AcronymList->new;

  # act
  my $result = ref $al->get_entry_list;

  # assert
  is($result,$expected,"get_entry_list")
}

######################################################################

1;
