#!/usr/bin/perl

# $Id: Demo.pm 230 2015-03-21 17:50:52Z drj826@gmail.com $

package SML::Demo;

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::Division';

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Demo');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has '+name' =>
  (
   default => 'DEMO',
  );

######################################################################

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 NAME

C<SML::Demo> - a region that represents a demonstration that an
instructor might give during a classroom presentation.

=head1 VERSION

2.0.0

=head1 SYNOPSIS

  extends SML::Division

  my $demo = SML::Demo->new
               (
                 id      => $id,
                 library => $library,
               );

=head1 DESCRIPTION

An SML demo is a region that represents a demonstration that an
instructor might give during a classroom presentation. Demos are
expressed as regions to they may contain environments like tables and
figures.

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
