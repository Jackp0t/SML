#!/usr/bin/perl

# $Id: Block.pm 255 2015-04-01 16:07:27Z drj826@gmail.com $

package SML::Block;

use Moose;

extends 'SML::Part';

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use lib "..";

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Block');

use Cwd;

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has 'line_list' =>
  (
   isa       => 'ArrayRef',
   reader    => 'get_line_list',
   default   => sub {[]},
  );

######################################################################

has 'containing_division' =>
  (
   isa       => 'SML::Division',
   reader    => 'get_containing_division',
   writer    => 'set_containing_division',
   predicate => 'has_containing_division',
  );

# The division that contains this block.

after 'set_containing_division' => sub {
  my $self = shift;
  my $cd   = $self->get_containing_division;
  $logger->trace("..... containing division for \'$self\' now: \'$cd\'");
};

######################################################################

has 'valid_syntax' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_syntax',
   lazy      => 1,
   builder   => 'validate_syntax',
  );

######################################################################

has 'valid_semantics' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_semantics',
   lazy      => 1,
   builder   => 'validate_semantics',
  );

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

sub add_line {

  # Add a line to this block.

  my $self = shift;
  my $line = shift;

  if ( $line->isa('SML::Line') )
    {
      push @{ $self->get_line_list }, $line;
      return 1;
    }

  else
    {
      $logger->("CAN'T ADD LINE \'$line\' is not a line");
      return 0;
    }

}

######################################################################

sub add_part {

  # Only a string can be part of a block.

  my $self = shift;
  my $part = shift;

  if (
      not
      (
       ref $part
       or
       $part->isa('SML::String')
      )
     )
    {
      $logger->error("CAN'T ADD PART \'$part\' is not a string");
      return 0;
    }

  # $part->set_containing_block( $self );

  push @{ $self->get_part_list }, $part;

  $logger->trace("add part $part");

  return 1;
}

######################################################################

sub get_first_line {

  # Return the first line of this block.

  my $self = shift;

  if ( defined $self->get_line_list->[0] )
    {
      return $self->get_line_list->[0];
    }

  else
    {
      # $logger->error("FIRST LINE DOESN'T EXIST");
      return 0;
    }
}

######################################################################

sub get_location {

  # Return the location (filespec + line number) of the first line of
  # this block.

  my $self = shift;

  my $line = $self->get_first_line;

  if ( ref $line and $line->isa('SML::Line') )
    {
      return $line->get_location;
    }

  else
    {
      return 'UNKNOWN LOCATION';
    }

}

######################################################################

sub is_in_a {

  # Return 1 if this block is "in a" division of "type" (even if it is
  # buried several divisions deep).

  my $self = shift;
  my $type = shift;

  my $division = $self->get_containing_division || q{};

  while ( $division )
    {
      if ( $division->isa($type) )
	{
	  return 1;
	}

      elsif ( $division->has_containing_division )
	{
	  $division = $division->get_containing_division;
	}

      else
	{
	  return 0;
	}
    }

  return 0;
}

######################################################################

sub validate_syntax {

  # Validate the syntax of this block.  Syntax validation is possible
  # even if the block is not in a document or library context.

  my $self  = shift;
  my $valid = 1;

  $valid = 0 if not $self->has_valid_bold_markup_syntax;
  $valid = 0 if not $self->has_valid_italics_markup_syntax;
  $valid = 0 if not $self->has_valid_fixedwidth_markup_syntax;
  $valid = 0 if not $self->has_valid_underline_markup_syntax;
  $valid = 0 if not $self->has_valid_superscript_markup_syntax;
  $valid = 0 if not $self->has_valid_subscript_markup_syntax;
  $valid = 0 if not $self->has_valid_cross_ref_syntax;
  $valid = 0 if not $self->has_valid_id_ref_syntax;
  $valid = 0 if not $self->has_valid_page_ref_syntax;
  $valid = 0 if not $self->has_valid_glossary_term_ref_syntax;
  $valid = 0 if not $self->has_valid_glossary_def_ref_syntax;
  $valid = 0 if not $self->has_valid_acronym_ref_syntax;
  $valid = 0 if not $self->has_valid_source_citation_syntax;

  return $valid;
}

######################################################################

sub validate_semantics {

  # Validate the semantics of this block.

  my $self  = shift;
  my $valid = 1;

  $valid = 0 if not $self->has_valid_cross_ref_semantics;
  $valid = 0 if not $self->has_valid_id_ref_semantics;
  $valid = 0 if not $self->has_valid_page_ref_semantics;
  $valid = 0 if not $self->has_valid_theversion_ref_semantics;
  $valid = 0 if not $self->has_valid_therevision_ref_semantics;
  $valid = 0 if not $self->has_valid_thedate_ref_semantics;
  $valid = 0 if not $self->has_valid_status_ref_semantics;
  $valid = 0 if not $self->has_valid_glossary_term_ref_semantics;
  $valid = 0 if not $self->has_valid_glossary_def_ref_semantics;
  $valid = 0 if not $self->has_valid_acronym_ref_semantics;
  $valid = 0 if not $self->has_valid_source_citation_semantics;
  $valid = 0 if not $self->has_valid_file_ref_semantics;

  return $valid;
}

######################################################################
######################################################################
##
## Private Attributes
##
######################################################################
######################################################################

has 'valid_bold_markup_syntax' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_bold_markup_syntax',
   lazy      => 1,
   builder   => '_validate_bold_markup_syntax',
  );

######################################################################

has 'valid_italics_markup_syntax' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_italics_markup_syntax',
   lazy      => 1,
   builder   => '_validate_italics_markup_syntax',
  );

######################################################################

has 'valid_fixedwidth_markup_syntax' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_fixedwidth_markup_syntax',
   lazy      => 1,
   builder   => '_validate_fixedwidth_markup_syntax',
  );

######################################################################

has 'valid_underline_markup_syntax' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_underline_markup_syntax',
   lazy      => 1,
   builder   => '_validate_underline_markup_syntax',
  );

######################################################################

has 'valid_superscript_markup_syntax' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_superscript_markup_syntax',
   lazy      => 1,
   builder   => '_validate_superscript_markup_syntax',
  );

######################################################################

has 'valid_subscript_markup_syntax' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_subscript_markup_syntax',
   lazy      => 1,
   builder   => '_validate_subscript_markup_syntax',
  );

######################################################################

has 'valid_cross_ref_syntax' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_cross_ref_syntax',
   lazy      => 1,
   builder   => '_validate_cross_ref_syntax',
  );

######################################################################

has 'valid_id_ref_syntax' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_id_ref_syntax',
   lazy      => 1,
   builder   => '_validate_id_ref_syntax',
  );

######################################################################

has 'valid_page_ref_syntax' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_page_ref_syntax',
   lazy      => 1,
   builder   => '_validate_page_ref_syntax',
  );

######################################################################

has 'valid_glossary_term_ref_syntax' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_glossary_term_ref_syntax',
   lazy      => 1,
   builder   => '_validate_glossary_term_ref_syntax',
  );

######################################################################

has 'valid_glossary_def_ref_syntax' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_glossary_def_ref_syntax',
   lazy      => 1,
   builder   => '_validate_glossary_def_ref_syntax',
  );

######################################################################

has 'valid_acronym_ref_syntax' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_acronym_ref_syntax',
   lazy      => 1,
   builder   => '_validate_acronym_ref_syntax',
  );

######################################################################

has 'valid_source_citation_syntax' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_source_citation_syntax',
   lazy      => 1,
   builder   => '_validate_source_citation_syntax',
  );

######################################################################

has 'valid_cross_ref_semantics' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_cross_ref_semantics',
   lazy      => 1,
   builder   => '_validate_cross_ref_semantics',
  );

######################################################################

has 'valid_id_ref_semantics' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_id_ref_semantics',
   lazy      => 1,
   builder   => '_validate_id_ref_semantics',
  );

######################################################################

has 'valid_page_ref_semantics' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_page_ref_semantics',
   lazy      => 1,
   builder   => '_validate_page_ref_semantics',
  );

######################################################################

has 'valid_theversion_ref_semantics' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_theversion_ref_semantics',
   lazy      => 1,
   builder   => '_validate_theversion_ref_semantics',
  );

######################################################################

has 'valid_therevision_ref_semantics' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_therevision_ref_semantics',
   lazy      => 1,
   builder   => '_validate_therevision_ref_semantics',
  );

######################################################################

has 'valid_thedate_ref_semantics' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_thedate_ref_semantics',
   lazy      => 1,
   builder   => '_validate_thedate_ref_semantics',
  );

######################################################################

has 'valid_status_ref_semantics' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_status_ref_semantics',
   lazy      => 1,
   builder   => '_validate_status_ref_semantics',
  );

######################################################################

has 'valid_glossary_term_ref_semantics' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_glossary_term_ref_semantics',
   lazy      => 1,
   builder   => '_validate_glossary_term_ref_semantics',
  );

######################################################################

has 'valid_glossary_def_ref_semantics' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_glossary_def_ref_semantics',
   lazy      => 1,
   builder   => '_validate_glossary_def_ref_semantics',
  );

######################################################################

has 'valid_acronym_ref_semantics' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_acronym_ref_semantics',
   lazy      => 1,
   builder   => '_validate_acronym_ref_semantics',
  );

######################################################################

has 'valid_source_citation_semantics' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_source_citation_semantics',
   lazy      => 1,
   builder   => '_validate_source_citation_semantics',
  );

######################################################################

has 'valid_file_ref_semantics' =>
  (
   isa       => 'Bool',
   reader    => 'has_valid_file_ref_semantics',
   lazy      => 1,
   builder   => '_validate_file_ref_semantics',
  );

######################################################################
######################################################################
##
## Private Methods
##
######################################################################
######################################################################

sub _build_content {

  my $self  = shift;
  my $lines = [];

  if ( $self->get_name eq 'empty_block' )
    {
      return q{};
    }

  foreach my $line (@{ $self->get_line_list })
    {
      my $text = $line->get_content;

      $text =~ s/[\r\n]*$//;            # chomp

      push @{ $lines }, $text;
    }

  my $content = join(q{ }, @{ $lines });

  # trim whitespace from end of content
  $content =~ s/\s*$//;

  return $content;
}

######################################################################

sub _validate_theversion_ref_semantics {

  my $self = shift;

  my $library = $self->get_library;
  my $syntax  = $library->get_syntax;
  my $util    = $library->get_util;
  my $text    = $self->get_content;

  if ( not $text =~ /$syntax->{theversion_ref}/xms )
    {
      return 1;
    }

  $text = $util->remove_literals($text);

  my $valid = 1;
  my $doc   = $self->get_containing_document;

  if ( not $doc )
    {
      $logger->error("NOT IN DOCUMENT CONTEXT can't validate version references");
      return 0;
    }

  while ( $text =~ /$syntax->{theversion_ref}/xms )
    {
      if ( $doc->has_property('version') )
	{
	  $logger->trace("version reference is valid");
	}

      else
	{
	  my $location = $self->get_location;
	  $logger->warn("INVALID VERSION REFERENCE at $location document has no version property");
	  $valid = 0;
	}

      $text =~ s/$syntax->{theversion_ref}//xms;
    }

  return $valid;
}

######################################################################

sub _validate_therevision_ref_semantics {

  my $self = shift;

  my $library = $self->get_library;
  my $syntax  = $library->get_syntax;
  my $util    = $library->get_util;
  my $text    = $self->get_content;

  if ( not $text =~ /$syntax->{therevision_ref}/xms )
    {
      return 1;
    }

  $text = $util->remove_literals($text);

  my $valid = 1;
  my $doc   = $self->get_containing_document;

  if ( not $doc )
    {
      $logger->error("NOT IN DOCUMENT CONTEXT can't validate revision references");
      return 0;
    }

  while ( $text =~ /$syntax->{therevision_ref}/xms )
    {
      if ( $doc->has_property('revision') )
	{
	  $logger->trace("revision reference is valid");
	}

      else
	{
	  my $location = $self->get_location;
	  $logger->warn("INVALID REVISION REFERENCE at $location document has no revision property");
	  $valid = 0;
	}

      $text =~ s/$syntax->{therevision_ref}//xms;
    }

  return $valid;
}

######################################################################

sub _validate_thedate_ref_semantics {

  my $self = shift;

  my $library = $self->get_library;
  my $syntax  = $library->get_syntax;
  my $util    = $library->get_util;
  my $text    = $self->get_content;

  if ( not $text =~ /$syntax->{thedate_ref}/xms )
    {
      return 1;
    }

  $text = $util->remove_literals($text);

  my $valid = 1;
  my $doc   = $self->get_containing_document;

  if ( not $doc )
    {
      $logger->error("NOT IN DOCUMENT CONTEXT can't validate date references");
      return 0;
    }

  while ( $text=~ /$syntax->{thedate_ref}/xms )
    {
      if ( $doc->has_property('date') )
	{
	  $logger->trace("date reference is valid");
	}

      else
	{
	  my $location = $self->get_location;
	  $logger->warn("INVALID DATE REFERENCE at $location document has no date property");
	  $valid = 0;
	}

      $text =~ s/$syntax->{thedate_ref}//xms;
    }

  return $valid;
}

######################################################################

sub _validate_status_ref_semantics {

  # [status:td-000020]
  # [status:green]
  # [status:yellow]
  # [status:red]
  # [status:grey]

  my $self = shift;

  my $library = $self->get_library;
  my $syntax  = $library->get_syntax;
  my $util    = $library->get_util;
  my $valid   = 1;
  my $text    = $self->get_content;

  if ( not $text =~ /$syntax->{status_ref}/xms )
    {
      return 1;
    }

  $text = $util->remove_literals($text);

  while ( $text =~ /$syntax->{status_ref}/xms )
    {
      my $id_or_color = $1;

      if ( $id_or_color =~ $syntax->{valid_status} )
	{
	  my $color = $id_or_color;
	}

      else
	{
	  my $id = $id_or_color;

	  if ( not $self->get_containing_document )
	    {
	      $logger->error("NOT IN DOCUMENT CONTEXT can't validate status references");
	      return 0;
	    }

	  if ( $library->has_division($id) )
	    {
	      my $division = $library->get_division($id);

	      if ( not $division->has_property('status') )
		{
		  my $location = $self->get_location;
		  $logger->warn("INVALID STATUS REFERENCE at $location \'$id\' has no status property");
		  $valid = 0;
		}
	    }

	  else
	    {
	      my $location = $self->get_location;
	      $logger->warn("INVALID STATUS REFERENCE at $location \'$id\' not defined");
	      $valid = 0;
	    }
	}

      $text =~ s/$syntax->{status_ref}//xms;
    }

  return $valid;
}

######################################################################

sub _validate_glossary_term_ref_semantics {

  # Validate that each glossary term reference has a valid glossary
  # entry.  Glossary term references are inline tags like '[g:term]'
  # or '[g:namespace:term]'.

  my $self = shift;

  my $library = $self->get_library;
  my $syntax  = $library->get_syntax;
  my $util    = $library->get_util;
  my $text    = $self->get_content;

  if (
      not
      (
       $text =~ /$syntax->{gloss_term_ref}/xms
       or
       $text =~ /$syntax->{begin_gloss_term_ref}/xms
      )
     )
    {
      return 1;
    }

  $text = $util->remove_literals($text);

  my $valid = 1;

  if ( not $self->get_containing_document )
    {
      $logger->error("CAN'T VALIDATE GLOSSARY TERM REFERENCES not in document context");
      return 0;
    }

  while ( $text =~ /$syntax->{gloss_term_ref}/xms )
    {
      my $namespace = $3 || q{};
      my $term      = $4;

      if ( $library->get_glossary->has_entry($term,$namespace) )
	{
	  $logger->trace("term \'$term\' namespace \'$namespace\' is in glossary");
	}

      else
	{
	  my $location = $self->get_location;
	  $logger->warn("TERM NOT IN GLOSSARY \'$namespace\' \'$term\' at $location");
	  $valid = 0;
	}

      $text =~ s/$syntax->{gloss_term_ref}//xms;
    }

  return $valid;
}

######################################################################

sub _validate_glossary_def_ref_semantics {

  # Validate that each glossary definition reference has a valid
  # glossary entry.  Glossary definition references are inline tags
  # like '[def:term]'.

  my $self = shift;

  my $library = $self->get_library;
  my $syntax  = $library->get_syntax;
  my $util    = $library->get_util;
  my $text    = $self->get_content;

  if (
      not
      (
       $text =~ /$syntax->{gloss_def_ref}/xms
       or
       $text =~ /$syntax->{begin_gloss_def_ref}/xms
      )
     )
    {
      return 1;
    }

  $text = $util->remove_literals($text);

  my $valid = 1;

  if ( not $self->get_containing_document )
    {
      $logger->error("NOT IN DOCUMENT CONTEXT can't validate glossary definition references");
      return 0;
    }

  while ( $text =~ /$syntax->{gloss_def_ref}/xms )
    {
      my $namespace = $2 || q{};
      my $term      = $3;

      if ( $library->get_glossary->has_entry($term,$namespace) )
	{
	  $logger->trace("definition \'$term\' namespace \'$namespace\' is in glossary");
	}

      else
	{
	  my $location = $self->get_location;
	  $logger->warn("DEFINITION NOT IN GLOSSARY \'$namespace\' \'$term\' at $location");
	  $valid = 0;
	}

      $text =~ s/$syntax->{gloss_def_ref}//xms;
    }

  return $valid;
}

######################################################################

sub _validate_acronym_ref_semantics {

  # Validate that each acronym reference has a valid acronym list
  # entry.  Acronym references are inline tags like '[ac:term]'
  # or '[ac:namespace:term]'.

  my $self = shift;

  my $library = $self->get_library;
  my $syntax  = $library->get_syntax;
  my $util    = $library->get_util;
  my $text    = $self->get_content;

  if (
      not
      (
       $text =~ /$syntax->{acronym_term_ref}/xms
       or
       $text =~ /$syntax->{begin_acronym_term_ref}/xms
      )
     )
    {
      return 1;
    }

  $text = $util->remove_literals($text);

  my $valid = 1;

  if ( not $self->get_containing_document )
    {
      $logger->error("CAN'T VALIDATE ACRONYM REFERENCES: not in document context");
      return 0;
    }

  while ( $text =~ /$syntax->{acronym_term_ref}/xms )
    {
      my $namespace = $3 || q{};
      my $acronym   = $4;

      if ( $library->get_acronym_list->has_acronym($acronym,$namespace) )
	{
	  $logger->trace("acronym \'$acronym\' namespace \'$namespace\' is in acronym list");
	}

      else
	{
	  my $location = $self->get_location;
	  $logger->warn("ACRONYM NOT IN ACRONYM LIST: \'$acronym\' \'$namespace\' at $location");
	  $valid = 0;
	}

      $text =~ s/$syntax->{acronym_term_ref}//xms;
    }

  return $valid;
}

######################################################################

sub _validate_source_citation_semantics {

  # Validate that each source citation has a valid source in the
  # library's list of references.  Source citations are inline tags
  # like '[cite:cms15]'

  my $self = shift;

  my $library = $self->get_library;
  my $syntax  = $library->get_syntax;
  my $util    = $library->get_util;
  my $text    = $self->get_content;

  if (
      not
      (
       $text =~ /$syntax->{citation_ref}/xms
       or
       $text =~ /$syntax->{begin_citation_ref}/xms
      )
     )
    {
      return 1;
    }

  $text = $util->remove_literals($text);

  my $valid = 1;

  if ( not $self->get_containing_document )
    {
      $logger->error("NOT IN DOCUMENT CONTEXT can't validate source citations");
      return 0;
    }

  while ( $text =~ /$syntax->{citation_ref}/xms )
    {
      my $source = $2;
      my $note   = $3;

      if ( not $library->get_references->has_source($source) )
	{
	  my $location = $self->get_location;
	  $logger->warn("INVALID SOURCE CITATION source \'$source\' not defined at $location");
	  $valid = 0;
	}

      $text =~ s/$syntax->{citation_ref}//xms;
    }

  return $valid;
}

######################################################################

sub _validate_file_ref_semantics {

  # Validate that each file reference ('file:: file.txt' or 'image::
  # image.png') points to a valid file.

  my $self = shift;

  my $library = $self->get_library;
  my $syntax  = $library->get_syntax;
  my $util    = $library->get_util;
  my $text    = $self->get_content;

  if (
      not
      (
       $text =~ /$syntax->{file_element}/xms
       or
       $text =~ /$syntax->{image_element}/xms
      )
     )
    {
      return 1;
    }

  $text = $util->remove_literals($text);

  my $directory_path = $library->get_directory_path;
  my $valid          = 1;
  my $found_file     = 0;
  my $resource_spec;

  if ( $text =~ /$syntax->{file_element}/xms )
    {
      $resource_spec = $1;
    }

  if ( $text =~ /$syntax->{image_element}/xms )
    {
      $resource_spec = $3;
    }

  if ( -f "$directory_path/$resource_spec" )
    {
      $found_file = 1;
    }

  foreach my $path (@{ $library->get_include_path })
    {
      if ( -f "$directory_path/$path/$resource_spec" )
	{
	  $found_file = 1;
	}
    }

  if ( not $found_file )
    {
      $valid = 0;
      my $location = $self->get_location;
      $logger->warn("FILE NOT FOUND \'$resource_spec\' at $location");
    }

  return $valid;
}

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::Block> - one or more contiguous L<"SML::Line">s.

=head1 VERSION

2.0.0

=head1 SYNOPSIS

  extends SML::Part

  my $block = SML::Block->new
                (
                  name    => $name,
                  library => $library,
                );

  my $list     = $block->get_line_list;
  my $division = $block->get_containing_division;
  my $boolean  = $block->set_containing_division($division);
  my $boolean  = $block->has_containing_division;
  my $boolean  = $block->has_valid_syntax;
  my $boolean  = $block->has_valid_semantics;
  my $boolean  = $block->add_line($line);
  my $boolean  = $block->add_part($part);
  my $line     = $block->get_first_line;
  my $string   = $block->get_location;
  my $boolean  = $block->is_in_a($division_type);

=head1 DESCRIPTION

A block is one or more contiguous whole lines of text.  Blocks are
separated by blank lines and therefore cannot contain blank lines.
Blocks may contain inline text elements

=head1 METHODS

=head2 get_name_path

=head2 get_line_list

=head2 get_containing_division

=head2 set_containing_division($division)

=head2 has_containing_division

=head2 has_valid_syntax

=head2 has_valid_semantics

=head2 add_line($line)

=head2 add_part($part)

=head2 get_first_line

=head2 get_location

=head2 is_in_a($division_type)

=head1 AUTHOR

Don Johnson (drj826@acm.org)

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2012,2013 Don Johnson (drj826@acm.org)

Distributed under the terms of the Gnu General Public License (version
2, 1991)

This software is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
License for more details.

MODIFICATIONS AND ENHANCEMENTS TO THIS SOFTWARE OR WORKS DERIVED FROM
THIS SOFTWARE MUST BE MADE FREELY AVAILABLE UNDER THESE SAME TERMS.

=cut
