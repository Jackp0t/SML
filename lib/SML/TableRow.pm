#!/usr/bin/perl

# $Id: TableRow.pm 11633 2012-12-04 23:07:21Z don.johnson $

package SML::TableRow;

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::Division';

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.tablerow');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has '+name' =>
  (
   default => 'TABLEROW',
  );

######################################################################

# has '+type' =>
#   (
#    default => 'TABLEROW',
#   );

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::TableRow> - an environment that instructs the publishing
application to insert a table row into the document.

=head1 VERSION

This documentation refers to L<"SML::TableRow"> version 2.0.0.

=head1 SYNOPSIS

  my $tblrow = SML::TableRow->new();

=head1 DESCRIPTION

An SML table row environment instructs the publishing application to
insert a table row into the document.

=head1 METHODS

=head2 get_name

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