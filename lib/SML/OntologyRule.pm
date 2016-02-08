#!/usr/bin/perl

package SML::OntologyRule;              # ci-000458

use Moose;

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.OntologyRule');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has id =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_id',
   required => 1,
  );

# Unique identifier of this ontology rule.

######################################################################

has ontology =>
  (
   is       => 'ro',
   isa      => 'SML::Ontology',
   reader   => 'get_ontology',
   required => 1,
  );

# Ontology to which this rule belongs.

######################################################################

has rule_type =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_rule_type',
   required => 1,
  );

# One of:
#
#   div => division declaration rule
#   prp => property declaration rule
#   enu => enumeration declaration rule
#   cmp => composition declaration rule
#   def => default value declaration rule

######################################################################

has division_name =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_division_name',
   required => 1,
  );

######################################################################

has property_name =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_property_name',
   required => 1,
  );

# Must be a declared property.

######################################################################

has value_type =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_value_type',
   required => 1,
  );

######################################################################

has name_or_value =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_name_or_value',
   required => 1,
  );

######################################################################

has inverse_rule_id =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_inverse_rule_id',
   required => 1,
  );

######################################################################

has cardinality =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_cardinality',
   required => 1,
  );

# 1 or many

######################################################################

has required =>
  (
   is       => 'ro',
   isa      => 'Bool',
   reader   => 'is_required',
   required => 1,
  );

######################################################################

has imply_only =>
  (
   is       => 'ro',
   isa      => 'Bool',
   reader   => 'is_imply_only',
   required => 1,
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

sub BUILD {

  my $self = shift;

  my $ontology      = $self->get_ontology;
  my $library       = $ontology->get_library;
  my $syntax        = $library->get_syntax;
  my $id            = $self->get_id;
  my $rule_type     = $self->get_rule_type;
  my $division_name = $self->get_division_name;
  my $cardinality   = $self->get_cardinality;

  # validate rule type
  unless ( $rule_type =~ /$syntax->{valid_ontology_rule_type}/xms )
    {
      $logger->warn("INVALID RULE TYPE \'$rule_type\' in \'$id\'");
      return 0;
    }

  # validate division name
  if (
      $rule_type eq 'prp'
      or
      $rule_type eq 'enu'
      or
      $rule_type eq 'cmp'
      or
      $rule_type eq 'def'
     )
    {
      unless ( $ontology->has_division_with_name($division_name) )
	{
	  $logger->warn("INVALID DIVISION IN ONTOLOGY RULE \'$division_name\' in \'$id\'");
	  return 0;
	}
    }

  # validate cardinality value
  unless ( $cardinality =~ /$syntax->{valid_cardinality_value}/xms )
    {
      $logger->warn("INVALID CARDINALITY: \"$cardinality\" in $id");
      return 0;
    }

  return 1;
}

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::OntologyRule> - a rule that asserts a triple about
L<"SML::Entity">s and how they may relate to one another.

=head1 VERSION

This documentation refers to L<"SML::OntologyRule"> version 2.0.0.

=head1 SYNOPSIS

  my $or = SML::OntologyRule->new();

=head1 DESCRIPTION

An ontology rule asserts one of four facts: (1) the ontology contains
a named entity (class rule), (2) a named entity has a named property
of specified type and cardinality (property rule), (3) the value of a
property is allowed to be a specified value (enumerated value rule),
or (4) a named entity may contain another named entity (composition
rule).

=head1 METHODS

=head2 get_id

=head2 get_ontology

=head2 get_rule_type

=head2 get_division_name

=head2 get_property_name

=head2 get_value_type

=head2 get_name_or_value

=head2 get_inverse_rule_id

=head2 get_cardinality

=head2 is_required

=head2 is_imply_only

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
