#!/usr/bin/perl

package SML::Element;

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::Block';

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Element');

######################################################################

=head1 NAME

SML::Element - a name/value pair

=head1 SYNOPSIS

  SML::Element->new
    (
      name    => $name,
      library => $library,
    );

  $element->get_value;                            # Str
  $element->set_value($value);                    # Bool
  $element->has_value;                            # Bool

  # methods inherited from SML::Block...

  $block->get_line_list;                          # ArrayRef
  $block->get_containing_division;                # SML::Division
  $block->set_containing_division($division);     # Bool
  $block->has_containing_division;                # Bool
  $block->has_valid_syntax;                       # Bool
  $block->has_valid_semantics;                    # Bool
  $block->add_line($line);                        # Bool
  $block->add_part($part);                        # Bool
  $block->get_first_line;                         # SML::Line
  $block->get_location;                           # Str
  $block->is_in_a($division_name);                # Bool

  # methods inherited from SML::Part...

  $part->get_name;                                # Str
  $part->get_library;                             # SML::Library
  $part->get_id;                                  # Str
  $part->set_id;                                  # Bool
  $part->set_content;                             # Bool
  $part->get_content;                             # Str
  $part->has_content;                             # Bool
  $part->get_container;                           # SML::Part
  $part->set_container;                           # Bool
  $part->has_container;                           # Bool
  $part->get_part_list;                           # ArrayRef
  $part->is_narrative_part;                       # Bool

  $part->init;                                    # Bool
  $part->contains_parts;                          # Bool
  $part->has_part($id);                           # Bool
  $part->get_part($id);                           # SML::Part
  $part->add_part($part);                         # Bool
  $part->get_narrative_part_list                  # ArrayRef
  $part->get_containing_document;                 # SML::Document
  $part->is_in_section;                           # Bool
  $part->get_containing_section;                  # SML::Section
  $part->render($rendition,$style);               # Str
  $part->dump_part_structure($indent);            # Str

=head1 DESCRIPTION

An C<SML::Element> is an C<SML::Block> containing a name/value pair
expressing a piece of structured information (descriptive markup) or
instructing the publishing application to take some action (procedural
markup).

=head1 METHODS

=cut

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has '+name' =>
  (
   required => 1,
  );

######################################################################

has value =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_value',
   writer    => 'set_value',
   predicate => 'has_value',
  );

=head2 get_value

Return a scalar text value of the element.  This value may contain SML
markup.

  my $value = $element->get_value;

=head2 set_value

Set the value of the element.

  $element->set_value($value);

=head2 has_value

Return 1 if a value has been set for this element.

  my $result = $element->has_value;

=cut

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

# NONE

######################################################################
######################################################################
##
## Private Attributes
##
######################################################################
######################################################################

# NONE

######################################################################
######################################################################
##
## Private Methods
##
######################################################################
######################################################################

# NONE

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 AUTHOR

Don Johnson (drj826@acm.org)

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2012-2016 Don Johnson (drj826@acm.org)

Distributed under the terms of the Gnu General Public License (version
2, 1991)

This software is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
License for more details.

MODIFICATIONS AND ENHANCEMENTS TO THIS SOFTWARE OR WORKS DERIVED FROM
THIS SOFTWARE MUST BE MADE FREELY AVAILABLE UNDER THESE SAME TERMS.

=cut
