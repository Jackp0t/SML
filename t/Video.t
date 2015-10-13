#!/usr/bin/perl

# $Id: Video.t 259 2015-04-02 20:27:00Z drj826@gmail.com $

use lib "../lib";
use Test::More tests => 3;

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
my $library = $td->get_test_library_1;

#---------------------------------------------------------------------
# Can use module?
#---------------------------------------------------------------------

BEGIN {
  use SML::Video;
  use_ok( 'SML::Video' );
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

my $obj = SML::Video->new(id=>'vid1',library=>$library);

isa_ok($obj,'SML::Video');

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   'get_name',
  );

can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Returns expected values?
#---------------------------------------------------------------------

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

######################################################################
