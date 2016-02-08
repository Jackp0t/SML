#!/usr/bin/perl

package SML::Part;                      # ci-000436

use Moose;

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Part');

######################################################################

=head1 NAME

SML::Part - a document part

=head1 SYNOPSIS

  SML::Part->new
    (
      name    => $name,                           # Str
      library => $library,                        # SML::Library
    );

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

C<SML::Part> is an abstract class that represents a part of a
document.  L<"SML::Division">s, L<"SML::Block">s, and
L<"SML::String">s are three types of parts.

Parts contain other parts to form a tree.

A part may be either a data part or a narrative part.  A data part is
an element that represents data about the enclosing division and is
therefore not considered part of the narrative text.  Any part that
isn't a data part is a narrative part.

Data parts and narrative parts can appear in any order.  By
convention, however, authors often place the data parts at the
beginning of the division.

=head1 METHODS

=head2 new

Instantiate a new SML::Part.

  my $part = SML::Part->new(name=>$name,library=>$library);

=cut

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has name =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_name',
   required  => 1,
  );

=head2 get_name

Return a scalar text value of the part's name.  Every part has a name.

  my $name = $part->get_name;

=cut

######################################################################

has library =>
  (
   is        => 'ro',
   isa       => 'SML::Library',
   reader    => 'get_library',
   required  => 1,
  );

=head2 get_library

Return the L<"SML::Library"> to which this part belongs.  Every part
belongs to one and only one library.

  my $library = $part->get_library;

=cut

######################################################################

has id =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_id',
   writer    => 'set_id',
   default   => '',
  );

=head2 get_id

Return a scalar text value of the part's ID.  Some parts require ID's
others don't.

  my $id = $part->get_id;

=head2 set_id($id)

Return a boolean value.  Set the part ID to the specified scalar text
value.

  my $result = $part->set_id($id);

=cut

######################################################################

has content =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_content',
   writer    => 'set_content',
   predicate => 'has_content',
   clearer   => '_clear_content',
   lazy      => 1,
   builder   => '_build_content',
  );

=head2 get_content

Return a scalar text value of the part's content. This is the raw SML
text content of the part.

  my $text = $part->get_content;

=head2 set_content($text)

Return a boolean value.  Set the part content to the specified scalar
text.

  my $result = $part->set_content($text);

=head2 has_content

Return a boolean; 1 if the part has content, 0 otherwise.

  my $result = $part->has_content;

=cut

######################################################################

has container =>
  (
   is        => 'ro',
   isa       => 'SML::Part',
   reader    => 'get_container',
   writer    => 'set_container',
   predicate => 'has_container',
  );

=head2 get_container

Return the SML::Part that contains this one.

  my $part = $part->get_container;

=head2 set_container($part)

Return a boolean value; 1 if the operation succeeds, 0 if it fails.
Set this part's container to the SML::Part specified.

  my $result = $part->set_container($part);

=head2 has_container

Return a boolean value; 1 if this part has a container, 0 otherwise.

  my $result = $part->has_container;

=cut

######################################################################

has part_list =>
  (
   is        => 'ro',
   isa       => 'ArrayRef',
   reader    => 'get_part_list',
   writer    => '_set_part_list',
   clearer   => '_clear_part_list',
   predicate => '_has_part_list',
   default   => sub {[]},
  );

=head2 get_part_list

Return an ArrayRef to a list of parts that are part of this one.

  my $list = $part->get_part_list;

=cut

######################################################################

has is_narrative_part =>
  (
   is      => 'ro',
   isa     => 'Bool',
   reader  => 'is_narrative_part',
   lazy    => 1,
   builder => '_build_is_narrative_part',
  );

=head2 is_narrative_part

Return a boolean value; 1 if this part is a narrative part, 0
otherwise.  A narrative part is any part that is NOT a data part.  A
data part is an element that represents data about the enclosing
division and is therefore not considered part of the narrative text.

  my $result = $part->is_narrative_part;

=cut

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

sub init {

  # Clear the content and empty the part list.

  my $self = shift;

  $self->_clear_content;
  $self->_clear_part_list;
  $self->_set_part_list([]);

  return 1;
}

=head2 init

Return a boolean value; 1 means success, 0 means fail.  Initialize the
part.  Clear the part content and empty the part list.

  my $result = $part->init;

=cut

######################################################################

sub contains_parts {

  # Return the number of parts in the part list.  This is typically
  # used within a conditional to determine whether or not this part
  # has parts.

  my $self = shift;

  if ( scalar @{ $self->get_part_list } )
    {
      return 1;
    }

  return 0;
}

=head2 contains_parts

Return a boolean value; 1 if the part contains other parts, 0
otherwise.

  my $result = $part->contains_parts;

=cut

######################################################################

sub has_part {

  # Return 1 if this part contains a part with the specified ID.

  my $self = shift;
  my $id   = shift;

  if ( not $id )
    {
      $logger->logdie("YOU MUST PROVIDE AN ID");
    }

  if ( $self->contains_parts )
    {
      foreach my $part (@{ $self->get_part_list })
	{
	  if ( $part->get_id eq $id )
	    {
	      return 1;
	    }

	  elsif ( $part->contains_parts )
	    {
	      if ( $part->has_part($id) )
		{
		  return 1;
		}
	    }
	}
    }

  return 0;
}

=head2 has_part($id)

Return a boolean value; 1 if the part contains the specified part ID,
0 otherwise.  This method walks the entire part structure looking for
the part with the specified ID.

  my $result = $part->has_part($id);

=cut

######################################################################

sub get_part {

  # Return the part if this part IS the part, or contains the part
  # with the specified ID.

  my $self = shift;
  my $id   = shift;

  unless ( $id )
    {
      $logger->logdie("CAN'T GET PART, MISSING ARGUMENT");
      return 0;
    }

  if ( $self->get_id eq $id )
    {
      return $self;
    }

  elsif ( $self->contains_parts )
    {
      foreach my $part (@{ $self->get_part_list })
	{
	  if ( $part->get_id eq $id )
	    {
	      return $part;
	    }

	  elsif ( $part->contains_parts )
	    {
	      if ( my $subpart = $part->get_part($id) )
		{
		  return $subpart;
		}
	    }
	}
    }

  # $logger->error("COULDN'T GET PART $id");
  return 0;
}

=head2 get_part($id)

Return an SML::Part with the specified part ID.  This method walks the
entire part structure looking for the part with the specified ID.

  my $part = $part->get_part($id);

=cut

######################################################################

sub add_part {

  # Add a part to the part list.

  my $self = shift;
  my $part = shift;

  push @{ $self->get_part_list }, $part;

  $logger->trace("add part $part");

  return 1;
}

=head2 add_part($part)

Return a boolean value; 1 if the operation succeeds, 0 otherwise.  Add
the specified part to this part's part list.

  my $result = $part->add_part($part);

=cut

######################################################################

sub get_narrative_part_list {

  my $self = shift;

  my $part_list           = $self->get_part_list;
  my $narrative_part_list = [];

  foreach my $part (@{ $part_list })
    {
      if ( $part->is_narrative_part )
	{
	  push(@{ $narrative_part_list }, $part);
	}
    }

  return $narrative_part_list;
}

=head2 get_narrative_part_list

Return an ArrayRef to a list of narrative parts within this part.

  my $list = $part->get_narrative_part_list;

=cut

######################################################################

sub get_containing_document {

  # Return the document to which this part belongs.

  my $self = shift;

  my $division = $self->get_containing_division;

  unless ( defined $division )
    {
      # $logger->error("DIVISION DOESN'T EXIST");
      return 0;
    }

  my $name = $division->get_name;

  if ( $name eq 'DOCUMENT' )
    {
      return $division;
    }

  else
    {
      return $division->get_containing_document;
    }
}

=head2 get_containing_document

Return the SML::Document that contains this part.

  my $document = $part->get_containing_document;

=cut

######################################################################

sub is_in_section {

  # Return 1 if this part is inside a section.

  my $self = shift;

  my $division = $self->get_containing_division;

  while ( ref $division and not $division->isa('SML::Document') )
    {
      if ( $division->isa('SML::Section') )
	{
	  return 1;
	}

      else
	{
	  $division = $division->get_containing_division;
	}
    }

  return 0;
}

=head2 is_in_section

Return a boolean value; 1 if this part is inside a section, 0
otherwise.

  my $result = $part->is_in_section;

=cut

######################################################################

sub get_containing_section {

  # Return the section to which this part belongs.

  my $self = shift;

  if ( $self->isa('SML::Section') )
    {
      return $self;
    }

  my $division = $self->get_containing_division;

  while ( ref $division and not $division->isa('SML::Document') )
    {
      if ( $division->isa('SML::Section') )
	{
	  return $division;
	}

      else
	{
	  $division = $division->get_containing_division;
	}
    }

  return 0;
}

=head2 get_containing_section

Return the SML::Section containing this part.

  my $section = $part->get_containing_section;

=cut

######################################################################

sub render {

  # Render the part using the specified rendition and style.

  my $self = shift;

  my $rendition = shift;
  my $style     = shift;

  my $library      = $self->get_library;
  my $util         = $library->get_util;
  my $template_dir = $library->get_template_dir;
  my $name         = $self->get_name;
  my $input        = "$name.tt";
  my $text         = q{};

  $template_dir = "$template_dir/$rendition/$style";

  if ( not -d $template_dir )
    {
      $logger->error("MISSING TEMPLATE DIRECTORY $template_dir");
      return q{};
    }

  my $config = {};

  $config->{INCLUDE_PATH} = $template_dir;
  $config->{RECURSION}    = 1;
  # $config->{DEBUG}        = 'dirs';

  my $tt = Template->new($config) || die "$Template::ERROR\n";

  my $vars = { self => $self };

  $tt->process($input,$vars,\$text);

  $text =~ s/\r\n?/\n/g;

  return $text;
}

=head2 render($rendition,$style)

Return a scalar text value of this part rendered in the specified
rendition and style.

  my $text = $part->render($rendition,$style)

=cut

######################################################################

sub dump_part_structure {

  my $self   = shift;
  my $indent = shift || q{};

  my $structure = q{};
  my $summary   = substr($self->get_content,0,40);

  $summary =~ s/[\r\n]*$//;     # chomp
  $summary =~ s/[\r\n]+/.../;   # compress newlines

  $structure .= $indent . $self->get_name . " ($summary)\n";

  $indent = $indent . '  ';

  foreach my $part (@{ $self->get_part_list })
    {
      $structure .= $part->dump_part_structure($indent);
    }

  return $structure;
}

=head2 dump_part_structure($indent)

Return a scalar text value of this part's internal tree structure.

  my $text = $part->dump_part_structure($indent);

=cut

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

sub _build_content {

  return q{};

}

######################################################################

sub _build_is_narrative_part {

  my $self = shift;

  my $library  = $self->get_library;
  my $ontology = $library->get_ontology;

  if ( $self->isa('SML::Element') )
    {
      my $name = $self->get_name;

      unless ( $ontology->property_is_universal($name) )
	{
	  return 0;
	}
    }

  return 1;
}

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 AUTHOR

Don Johnson (drj826@acm.org)

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2012,2016 Don Johnson (drj826@acm.org)

Distributed under the terms of the Gnu General Public License (version
2, 1991)

This software is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
License for more details.

MODIFICATIONS AND ENHANCEMENTS TO THIS SOFTWARE OR WORKS DERIVED FROM
THIS SOFTWARE MUST BE MADE FREELY AVAILABLE UNDER THESE SAME TERMS.

=cut
