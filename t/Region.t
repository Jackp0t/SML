#!/usr/bin/perl

# $Id: Region.t 15151 2013-07-08 21:01:16Z don.johnson $

use lib "..";
use Test::More tests => 4;
use Test::Perl::Critic (-severity => 4);

use SML;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

#---------------------------------------------------------------------
# Test Data
#---------------------------------------------------------------------

#---------------------------------------------------------------------
# Can use module?
#---------------------------------------------------------------------

BEGIN {
  use SML::Region;
  use_ok( 'SML::Region' );
}

#---------------------------------------------------------------------
# Follows coding standards?
#---------------------------------------------------------------------

critic_ok('../SML/Region.pm');

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

my $obj = SML::Region->new(id=>'reg1',name=>'problem');
isa_ok( $obj, 'SML::Region' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   'get_id',
   'as_text',
   'as_latex',
   'as_csv',
   'as_xml',
  );

can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Implements designed private methods?
#---------------------------------------------------------------------

my @private_methods =
  (
  );

# can_ok( $obj, @private_methods );

#---------------------------------------------------------------------
# Returns expected values?
#---------------------------------------------------------------------

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

######################################################################
