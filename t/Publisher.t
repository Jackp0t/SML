#!/usr/bin/perl

# $Id: Publisher.t 125 2015-02-24 02:43:25Z drj826@gmail.com $

use lib "../lib";
use Test::More;

use SML;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

#---------------------------------------------------------------------
# Test Data
#---------------------------------------------------------------------

use SML::TestData;

my $td = SML::TestData->new();
my $tcl = $td->get_publisher_test_case_list;

#---------------------------------------------------------------------
# Can use module?
#---------------------------------------------------------------------

BEGIN {
  use SML::Publisher;
  use_ok( 'SML::Publisher' );
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

my $args = {};
$args->{library} = $td->get_test_library_1;

my $obj = SML::Publisher->new(%{$args});
isa_ok( $obj, 'SML::Publisher' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   'get_library',                       # library to which this publisher belongs
   'publish',                           # publish somthing
  );

can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Returns expected values?
#---------------------------------------------------------------------

foreach my $tc (@{ $tcl })              # foreach test case in test case list
  {
    publish_ok($tc,'html','default') if defined $tc->{expected}{publish}{html}{default};
  }

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

######################################################################

sub publish_ok {

  my $tc        = shift;                # test case
  my $rendition = shift;                # html, latex, or pdf
  my $style     = shift;                # default

  # arrange
  my $tcname    = $tc->{name};
  my $object    = $tc->{object};
  my $expected  = $tc->{expected}{publish}{$rendition}{$style};
  my $args      = $tc->{args};
  my $publisher = SML::Publisher->new(%{$args});

    # act
  my $result = $publisher->publish($object,$rendition,$style);

  # assert
  is($result,$expected,"$tcname publish $rendition $style");
}

######################################################################

done_testing()
