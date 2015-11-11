#!/usr/bin/perl

# $Id: Index.pm 214 2015-03-13 21:03:43Z drj826@gmail.com $

package SML::Index;

use Moose;

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Index');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

sub add_entry {

  my $self  = shift;
  my $entry = shift;

  unless
    (
     ( ref $entry )
     and
     ( $entry->isa('SML::IndexEntry') )
    )
    {
      $logger->error("NOT AN INDEX ENTRY, CAN'T ADD TO INDEX \'$entry\'");
      return 0;
    }

  my $hash = $self->_get_entry_hash;
  my $term = $entry->get_term;

  if ( exists $hash->{$term} )
    {
      $logger->error("ENTRY ALREADY IN INDEX \'$term\'");
    }

  $hash->{$term} = $entry;

  return 1;
}

######################################################################

sub has_entry {

  my $self = shift;
  my $term = shift;

  my $hash = $self->_get_entry_hash;

  if ( exists $hash->{$term} )
    {
      return 1;
    }

  else
    {
      return 0;
    }
}

######################################################################

sub get_entry {

  my $self = shift;
  my $term = shift;

  if ( $self->has_entry($term) )
    {
      my $hash = $self->_get_entry_hash;

      return $hash->{$term};
    }

  else
    {
      $logger->error("NO INDEX ENTRY: \'$term\'");
      return 0;
    }
}

######################################################################

sub get_entry_list {

  my $self = shift;

  my $hash = $self->_get_entry_hash;
  my $list = [];

  foreach my $term ( sort keys %{ $hash } )
    {
      my $entry = $hash->{$term};

      push(@{$list},$entry);
    }

  return $list;
}

######################################################################

sub has_entries {

  # Return 1 if the index has any entries.

  my $self = shift;

  if ( scalar keys %{ $self->_get_entry_hash } )
    {
      return 1;
    }

  else
    {
      return 0;
    }
}

######################################################################
######################################################################
##
## Private Attributes
##
######################################################################
######################################################################

has 'entry_hash' =>
  (
   isa     => 'HashRef',
   reader  => '_get_entry_hash',
   default => sub {{}},
  );

#   $hash->{$term} = $entry;

######################################################################
######################################################################
##
## Private Methods
##
######################################################################
######################################################################

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::Index> - a list of terms in a special subject, field, or
area of usage, with accompanying definitions.

=head1 VERSION

This documentation refers to L<"SML::Index"> version 2.0.0.

=head1 SYNOPSIS

  my $gloss = SML::Index->new();

=head1 DESCRIPTION

A index is a list of terms in a special subject, field, or area of
usage, with accompanying definitions.

=head1 METHODS

=head2 add_entry

Add a index entry.

=head2 has_entry

Check whether a specific index entry exists.

=head2 get_entry

Return a specific index entry.

=head2 get_entry_list

Return an alphabetically sorted list of all index entries.

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
