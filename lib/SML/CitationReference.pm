#!/usr/bin/perl

package SML::CitationReference;         # ci-000442

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::String';                  # ci-000438

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.CitationReference');

######################################################################

=head1 NAME

SML::CitationReference - cite a source

=head1 SYNOPSIS

  SML::CitationReference->new
    (
      tag             => $tag,
      source_id       => $source_id,
      details         => $details,
      library         => $library,
      containing_part => $part,
    );

  $ref->get_tag;                        # Str
  $ref->get_source_id;                  # Str
  $ref->get_details;                    # Str

=head1 DESCRIPTION

SML::CitationReference Extends L<SML::String> to represent a citation
to a C<SML::Source>.

=head1 METHODS

=cut

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has tag =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_tag',
   required => 1,
  );

=head2 get_tag

Return a scalar text value of the tag (either 'cite' or 'c').

  my $tag = $citation_ref->get_tag;

For example, if the citation reference is C<[cite:cms15, pg 44]> then
the tag is C<cite>.

=cut

######################################################################

has source_id =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_source_id',
   required => 1,
  );

=head2 get_source_id

Return a scalar text value which is the ID of the referenced source.

  my $id = $citation_ref->get_source_id;

For example, if the citation reference is C<[cite:cms15, pg 44]> then
the ID is C<cms15>.

=cut

######################################################################

has details =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_details',
   default  => '',
  );

=head2 get_details

Return a scalar text value which is the 'details' portion of the
reference.

  my $details = $citation_ref->get_details;

For example, if the citation reference is C<[cite:cms15, pg 44]> then
the 'details' part is C<pg 44>.

=cut

######################################################################

has '+content' =>
  (
   required  => 0,
  );

######################################################################

has '+name' =>
  (
   default => 'CITATION_REF',
  );

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
