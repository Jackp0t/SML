#!/usr/bin/perl

# $Id: File.t 196 2015-03-09 21:40:06Z drj826@gmail.com $

use lib "../lib";
use Test::More tests => 7;

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
my $tcl     = $td->get_file_test_case_list;
my $library = $td->get_test_library_1;

#---------------------------------------------------------------------
# Can use module?
#---------------------------------------------------------------------

BEGIN {
  use SML::File;
  use_ok( 'SML::File' );
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

my $obj = SML::File->new(filespec=>'td-000001.txt',library=>$library);
isa_ok( $obj, 'SML::File' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   # SML::File public attribute accessors
   'get_filespec',
   'get_filename',
   'get_directories',
   'get_path',
   'get_text',
   'get_line_list',
   'get_sha_digest',
   'get_md5_digest',
   'get_svninfo',
   'is_valid',

   # SML::File public methods
   # <none>
  );

can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Returns expected values?
#---------------------------------------------------------------------

foreach my $tc (@{ $tcl })
  {
    get_sha_digest_ok($tc) if defined $tc->{expected}{get_sha_digest};
    get_md5_digest_ok($tc) if defined $tc->{expected}{get_md5_digest};
    is_valid_ok($tc)       if defined $tc->{expected}{is_valid};
  }

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

######################################################################

sub get_sha_digest_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname   = $tc->{name};
  my $filespec = $tc->{filespec};
  my $library  = $tc->{library};
  my $expected = $tc->{expected}{get_sha_digest};
  my $file     = SML::File->new(filespec=>$filespec,library=>$library);

  # act
  my $result = $file->get_sha_digest;

  # assert
  is($result,$expected,"$tcname get_sha_digest $result" );
}

######################################################################

sub get_md5_digest_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname   = $tc->{name};
  my $filespec = $tc->{filespec};
  my $library  = $tc->{library};
  my $expected = $tc->{expected}{get_md5_digest};
  my $file     = SML::File->new(filespec=>$filespec,library=>$library);

  # act
  my $result = $file->get_md5_digest;

  # assert
  is($result,$expected,"$tcname get_md5_digest $result" );
}

######################################################################

sub is_valid_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname   = $tc->{name};
  my $filespec = $tc->{filespec};
  my $library  = $tc->{library};
  my $expected = $tc->{expected}{is_valid};
  my $file     = SML::File->new(filespec=>$filespec,library=>$library);

  # act
  my $result = $file->is_valid;

  # assert
  is($result,$expected,"$tcname is_valid $result");
}

######################################################################

1;
