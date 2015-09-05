#!/usr/bin/perl

# $Id: EmailAddress.pm 230 2015-03-21 17:50:52Z drj826@gmail.com $

package SML::EmailAddress;

use Moose;

use version; our $VERSION = qv('2.0.0');

extends 'SML::String';

use namespace::autoclean;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.EmailAddress');

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has '+name' =>
  (
   default => 'EMAIL_ADDR',
  );

######################################################################

has 'email_addr' =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_email_addr',
   required => 1,
  );

######################################################################
######################################################################
##
## Public Methods
##
######################################################################
######################################################################

######################################################################
######################################################################
##
## Private Attributes
##
######################################################################
######################################################################

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

C<SML::EmailAddress> - a string that represents an Email address

=head1 VERSION

2.0.0

=head1 SYNOPSIS

  extends SML::String

  example: [email:drj826@acm.org|Don Johnson]

  my $email = SML::EmailAddress->new
                (
                  email_addr      => $email_addr, # 'drj826@acm.org'
                  content         => $content,    # 'Don Johnson'
                  library         => $library,
                  containing_part => $part,
                );

  my $string = $email->get_email_addr;   # 'drj826@acm.org'
  my $string = $email->get_content;      # 'Don Johnson'

=head1 DESCRIPTION

Extends C<SML::String> to represent an Email address.

=head1 METHODS

=head2 get_email_addr

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
