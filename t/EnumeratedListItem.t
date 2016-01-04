#!/usr/bin/perl

use lib "../lib";
use Test::More tests => 5;

use SML;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

# set sml.Library logger to WARN
my $logger_library = Log::Log4perl::get_logger('sml.Library');
$logger_library->level('WARN');

#---------------------------------------------------------------------
# Test Data
#---------------------------------------------------------------------

use SML::TestData;

my $td      = SML::TestData->new;
my $tcl     = $td->get_enumerated_list_item_test_case_list;
my $library = $td->get_test_library_1;

#---------------------------------------------------------------------
# Can use module?
#---------------------------------------------------------------------

BEGIN {
  use SML::EnumeratedListItem;
  use_ok( 'SML::EnumeratedListItem' );
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

my $args = {};

$args->{library}            = $library;
$args->{leading_whitespace} = '';

my $obj = SML::EnumeratedListItem->new(%{$args});
isa_ok( $obj, 'SML::EnumeratedListItem' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   # SML::EnumeratedListItem public attribute accessors
   # <none>

   # SML::EnumeratedListItem public methods
   'get_value',
  );

can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Returns expected values?
#---------------------------------------------------------------------

foreach my $tc (@{ $tcl })
  {
    get_value_ok($tc) if defined $tc->{expected}{get_value};
  }

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

######################################################################

sub get_value_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname   = $tc->{name};
  my $text     = $tc->{text};
  my $line     = SML::Line->new(content=>$text);
  my $expected = $tc->{expected}{get_value};
  my $args     = {};

  $args->{library}            = $tc->{library};
  $args->{leading_whitespace} = $tc->{leading_whitespace};

  my $item = SML::EnumeratedListItem->new(%{$args});

  $item->add_line($line);

  # act
  my $result = $item->get_value;

  # assert
  is($result,$expected,"$tcname get_value $result");
}

######################################################################

1;
