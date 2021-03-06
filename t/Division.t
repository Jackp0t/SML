#!/usr/bin/perl

use lib "../lib";
use Test::More tests => 59;

use SML;

use Log::Log4perl;
Log::Log4perl->init("log.test.conf");

# set sml.Library logger to WARN
my $logger_library = Log::Log4perl::get_logger('sml.Library');
$logger_library->level('WARN');

# set sml.Parser logger to WARN
my $logger_parser = Log::Log4perl::get_logger('sml.Parser');
$logger_parser->level('WARN');

use Test::Log4perl;

#---------------------------------------------------------------------
# Test Data
#---------------------------------------------------------------------

use SML::TestData;

my $td      = SML::TestData->new();               # test data object
my $tcl     = $td->get_division_test_case_list;   # test case list
my $library = $td->get_test_library_1;

#---------------------------------------------------------------------
# Can use module?
#---------------------------------------------------------------------

BEGIN {
  use SML::Division;
  use_ok( 'SML::Division' );
}

#---------------------------------------------------------------------
# Can instantiate object?
#---------------------------------------------------------------------

my $args = {};

$args->{name}    = 'div';
$args->{id}      = 'my-div';
$args->{library} = $library;

my $obj = SML::Division->new(%{$args});
isa_ok( $obj, 'SML::Division' );

#---------------------------------------------------------------------
# Implements designed public methods?
#---------------------------------------------------------------------

my @public_methods =
  (
   # SML::Division public attribute accessors
   'get_number',
   'set_number',
   'get_previous_number',
   'set_previous_number',
   'get_next_number',
   'set_next_number',
   'get_containing_division',
   'set_containing_division',
   'has_containing_division',

   # SML::Division public methods
   'add_division',
   'add_part',
   'add_property',
   'add_property_element',
   'add_attribute',
   'contains_division',
   'has_property',
   'has_property_value',
   'has_attribute',
   'get_division_list',
   'has_sections',
   'has_tables',
   'has_figures',
   'has_attachments',
   'has_listings',
   'get_section_list',
   'get_block_list',
   'get_element_list',
   'get_line_list',
   'get_data_segment_line_list',
   'get_narrative_line_list',
   'get_first_part',
   'get_first_line',
   'get_property_list',
   'get_property',
   'get_property_value',
   'get_containing_document',
   'get_location',
   'get_section',
   'is_in_a',

   # SML::Part public attribute accessors (inherited)
   'get_id',
   'set_id',
   'get_name',
   'get_content',
   'set_content',
   'get_part_list',

   # SML::Part public methods (inherited)
   'init',
   'has_content',
   'contains_parts',
   'has_part',
   'get_part',
   'add_part',
   'get_containing_document',
   'is_in_section',
   'get_containing_section',
   'render',
   'dump_part_structure',
   'get_library',
  );

can_ok( $obj, @public_methods );

#---------------------------------------------------------------------
# Returns expected values?
#---------------------------------------------------------------------

foreach my $tc (@{ $tcl })
  {
    init_ok($tc)                    if defined $tc->{expected}{init};
    get_id_ok($tc)                  if defined $tc->{expected}{get_id};
    get_name_ok($tc)                if defined $tc->{expected}{get_name};
    get_number_ok($tc)              if defined $tc->{expected}{get_number};
    get_containing_division_ok($tc) if defined $tc->{expected}{get_containing_division};
    get_part_list_ok($tc)           if defined $tc->{expected}{get_part_list};
    get_line_list_ok($tc)           if defined $tc->{expected}{get_line_list};
    get_division_list_ok($tc)       if defined $tc->{expected}{get_division_list};
    get_section_list_ok($tc)        if defined $tc->{expected}{get_section_list};
    get_block_list_ok($tc)          if defined $tc->{expected}{get_block_list};
    get_element_list_ok($tc)        if defined $tc->{expected}{get_element_list};
    get_data_segment_line_list_ok($tc)  if defined $tc->{expected}{get_data_segment_line_list};
    get_narrative_line_list_ok($tc) if defined $tc->{expected}{get_narrative_line_list};
    get_first_part_ok($tc)          if defined $tc->{expected}{get_first_part};
    get_first_line_ok($tc)          if defined $tc->{expected}{get_first_line};
    get_property_list_ok($tc)       if defined $tc->{expected}{get_property_list};
    get_property_ok($tc)            if defined $tc->{expected}{get_property};
    get_property_value_ok($tc)      if defined $tc->{expected}{get_property_value};
  }

#---------------------------------------------------------------------
# Throws expected exceptions?
#---------------------------------------------------------------------

# foreach my $tc (@{ $tcl })
#   {
#     warn_is_valid_ok($tc) if defined $tc->{expected}{warning}{is_valid};
#   }

######################################################################

sub init_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname   = $tc->{name};
  my $expected = $tc->{expected}{init};
  my $args =
    {
     name    => $tc->{division_name},
     library => $tc->{library},
    };

  my $division = SML::Division->new(%{$args});

  # act
  my $result = $division->init;

  # assert
  is($result,$expected,"$tcname init $result");
}

######################################################################

sub get_id_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname   = $tc->{name};
  my $expected = $tc->{expected}{get_id};
  my $args =
    {
     id      => $tc->{divid},
     name    => $tc->{division_name},
     number  => $tc->{division_number},
     library => $tc->{library},
    };

  my $division = SML::Division->new(%{$args});

  # act
  my $result = $division->get_id;

  # assert
  is($result,$expected,"$tcname get_id $result");
}

######################################################################

sub get_name_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname   = $tc->{name};
  my $expected = $tc->{expected}{get_name};
  my $args =
    {
     name    => $tc->{division_name},
     library => $tc->{library},
    };

  my $division = SML::Division->new(%{$args});

  # act
  my $result = $division->get_name;

  # assert
  is($result,$expected,"$tcname get_name $result");
}

######################################################################

sub get_number_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname   = $tc->{name};
  my $expected = $tc->{expected}{get_number};
  my $args =
    {
     id      => $tc->{divid},
     name    => $tc->{division_name},
     number  => $tc->{division_number},
     library => $tc->{library},
    };

  my $division = SML::Division->new(%{$args});

  # act
  my $result = $division->get_number;

  # assert
  is($result,$expected,"$tcname get_number $result");
}

######################################################################

sub get_containing_division_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname   = $tc->{name};
  my $library  = $tc->{library};
  my $divid    = $tc->{divid};
  my $expected = $tc->{expected}{get_containing_division};
  my $division = $library->get_division($divid);

  # act
  my $result = ref $division->get_containing_division;

  # assert
  is($result,$expected,"$tcname get_containing_division $result");
}

######################################################################

sub get_part_list_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname   = $tc->{name};
  my $library  = $tc->{library};
  my $divid    = $tc->{divid};
  my $expected = $tc->{expected}{get_part_list};
  my $division = $library->get_division($divid);

  # act
  my $result = scalar @{ $division->get_part_list };

  # assert
  is($result,$expected,"$tcname get_part_list $result");
}

######################################################################

sub get_line_list_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname   = $tc->{name};
  my $library  = $tc->{library};
  my $divid    = $tc->{divid};
  my $expected = $tc->{expected}{get_line_list};
  my $division = $library->get_division($divid);

  # act
  my $result = scalar @{ $division->get_line_list };

  # assert
  is($result,$expected,"$tcname get_line_list $result");
}

######################################################################

sub get_division_list_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname   = $tc->{name};
  my $library  = $tc->{library};
  my $divid    = $tc->{divid};
  my $expected = $tc->{expected}{get_division_list};
  my $division = $library->get_division($divid);

  # act
  my $result = scalar @{ $division->get_division_list };

  # assert
  is($result,$expected,"$tcname get_division_list $result");
}

######################################################################

sub get_section_list_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname   = $tc->{name};
  my $library  = $tc->{library};
  my $divid    = $tc->{divid};
  my $expected = $tc->{expected}{get_section_list};
  my $division = $library->get_division($divid);

  # act
  my $result = scalar @{ $division->get_section_list };

  # assert
  is($result,$expected,"$tcname get_section_list $result");
}

######################################################################

sub get_block_list_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname   = $tc->{name};
  my $library  = $tc->{library};
  my $divid    = $tc->{divid};
  my $expected = $tc->{expected}{get_block_list};
  my $division = $library->get_division($divid);

  # act
  my $result = scalar @{ $division->get_block_list };

  # assert
  is($result,$expected,"$tcname get_block_list $result");
}

######################################################################

sub get_element_list_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname   = $tc->{name};
  my $library  = $tc->{library};
  my $divid    = $tc->{divid};
  my $expected = $tc->{expected}{get_element_list};
  my $division = $library->get_division($divid);

  # act
  my $result = scalar @{ $division->get_element_list };

  # assert
  is($result,$expected,"$tcname get_element_list $result");
}

######################################################################

sub get_data_segment_line_list_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname   = $tc->{name};
  my $library  = $tc->{library};
  my $divid    = $tc->{divid};
  my $expected = $tc->{expected}{get_data_segment_line_list};
  my $division = $library->get_division($divid);

  # act
  my $result = scalar @{ $division->get_data_segment_line_list };

  # assert
  is($result,$expected,"$tcname get_data_segment_line_list $result");
}

######################################################################

sub get_narrative_line_list_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname   = $tc->{name};
  my $library  = $tc->{library};
  my $divid    = $tc->{divid};
  my $expected = $tc->{expected}{get_narrative_line_list};
  my $division = $library->get_division($divid);

  # act
  my $result = scalar @{ $division->get_narrative_line_list };

  # assert
  is($result,$expected,"$tcname get_narrative_line_list $result");
}

######################################################################

sub get_first_part_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname   = $tc->{name};
  my $library  = $tc->{library};
  my $divid    = $tc->{divid};
  my $expected = $tc->{expected}{get_first_part};
  my $division = $library->get_division($divid);

  # act
  my $result = ref $division->get_first_part;

  # assert
  is($result,$expected,"$tcname get_first_part $result");
}

######################################################################

sub get_first_line_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname   = $tc->{name};
  my $library  = $tc->{library};
  my $divid    = $tc->{divid};
  my $expected = $tc->{expected}{get_first_line};
  my $division = $library->get_division($divid);

  # act
  my $line   = $division->get_first_line;
  my $result = $line->get_content;

  $result =~ s/[\r\n]*$//;              # chomp

  # assert
  is($result,$expected,"$tcname get_first_line $result");
}

######################################################################

sub get_property_list_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname   = $tc->{name};
  my $library  = $tc->{library};
  my $divid    = $tc->{divid};
  my $expected = $tc->{expected}{get_property_list};
  my $division = $library->get_division($divid);

  # act
  my $result = scalar @{ $division->get_property_list };

  # assert
  is($result,$expected,"$tcname get_property_list $result");
}

######################################################################

sub get_property_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname        = $tc->{name};
  my $library       = $tc->{library};
  my $divid         = $tc->{divid};
  my $property_name = $tc->{property_name};
  my $expected      = $tc->{expected}{get_property};
  my $division      = $library->get_division($divid);

  # act
  my $result = ref $division->get_property($property_name);

  # assert
  is($result,$expected,"$tcname get_property $result");
}

######################################################################

sub get_property_value_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname        = $tc->{name};
  my $library       = $tc->{library};
  my $divid         = $tc->{divid};
  my $property_name = $tc->{property_name};
  my $expected      = $tc->{expected}{get_property_value};
  my $division      = $library->get_division($divid);

  # act
  my $result = $division->get_property_value($property_name);

  # assert
  is($result,$expected,"$tcname get_property_value $result");
}

######################################################################

sub warn_is_valid_ok {

  my $tc = shift;                       # test case

  # arrange
  my $tcname   = $tc->{name};
  my $library  = $tc->{library};
  my $divid    = $tc->{divid};
  my $expected = $tc->{expected}{warning}{is_valid};
  my $division = $library->get_division($divid);
  my $t1logger = Test::Log4perl->get_logger('sml.Division');

  Test::Log4perl->start( ignore_priority => "info" );
  $t1logger->warn(qr/$expected/);

  # act
  $division->is_valid;

  # assert
  Test::Log4perl->end("$tcname $expected");
}

######################################################################

1;
