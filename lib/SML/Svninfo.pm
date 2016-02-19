#!/usr/bin/perl

package SML::Svninfo;                   # ci-000420

use Moose;

use version; our $VERSION = qv('2.0.0');

use namespace::autoclean;

use Date::Pcalc qw(:all);

use Cwd;

use Log::Log4perl qw(:easy);
with 'MooseX::Log::Log4perl';
my $logger = Log::Log4perl::get_logger('sml.Svninfo');

use SML::Options;

######################################################################

=head1 NAME

SML::Svninfo - SVN info about a file

=head1 SYNOPSIS

  SML::Svninfo->new(filespec=>$filespec);

  $svninfo->get_filename;               # Str
  $svninfo->get_library;                # SML::Library
  $svninfo->get_revision;               # Str
  $svninfo->get_date;                   # Str
  $svninfo->get_author;                 # Str
  $svninfo->has_been_modified;          # Bool
  $svninfo->get_days_old;               # Int

=head1 DESCRIPTION

Svninfo objects represent change control information about a file.

=head1 METHODS

=cut

######################################################################
######################################################################
##
## Public Attributes
##
######################################################################
######################################################################

has filename =>
  (
   is       => 'ro',
   isa      => 'Str',
   reader   => 'get_filename',
   required => 1,
  );

=head2 get_filename

Return a scalar text value which is the filename of the file under
revision control.

  my $filename = $svninfo->get_filename;

=cut

######################################################################

has library =>
  (
   is       => 'ro',
   isa      => 'SML::Library',
   reader   => 'get_library',
   required => 1,
  );

=head2 get_library

Return the C<SML::Library> to which this file belongs.

  my $library = $svninfo->get_library;

=cut

######################################################################

has revision =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_revision',
   writer    => 'set_revision',
   clearer   => 'clear_revision',
   predicate => 'has_revision',
  );

=head2 get_revision

Return a scalar text value which is the revision number of the current
file revision.

  my $revision = $svninfo->get_revision;

=cut

######################################################################

has date =>
  (
   is        => 'ro',
   isa       => 'Str',
   reader    => 'get_date',
   writer    => 'set_date',
   clearer   => 'clear_date',
   predicate => 'has_date',
   default   => 'unknown',
  );

=head2 get_date

Return a scalar text value which is the date of the most current
revision of the file.

  my $date = $svninfo->get_date;

=cut

######################################################################

has author =>
  (
   is      => 'ro',
   isa     => 'Str',
   reader  => 'get_author',
   writer  => 'set_author',
   default => 'unknown',
  );

=head2 get_author

Return a scalar text value which is the author (last individual to
edit the file).

  my $author = $svninfo->get_author;

=cut

######################################################################

has modified =>
  (
   is      => 'ro',
   isa     => 'Bool',
   reader  => 'has_been_modified',
   writer  => 'set_has_been_modified',
   default => 0,
  );

=head2 has_been_modified

Return 1 if the working copy of the file has been modified since the
last commit.

  my $result = $svninfo->has_been_modified;

=cut

######################################################################

has days_old =>
  (
   is      => 'ro',
   isa     => 'Int',
   reader  => 'get_days_old',
   writer  => 'set_days_old',
  );

=head2 get_days_old

Return an integer value which is the number of days since the last
revision of the file.

  my $age = $svninfo->get_days_old;

=cut

######################################################################

# has text =>
#   (
#    is      => 'ro',
#    isa     => 'Str',
#    reader  => 'get_text',
#    writer  => 'set_text',
#    default => '',
#   );

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

  my $self     = shift;

  my $library  = $self->get_library;
  my $filename = $self->get_filename;
  my $filespec = $library->get_filespec($filename);
  my $options  = $library->get_options;
  my $svn      = $self->_find_svn_executable;

  #-------------------------------------------------------------------
  # Ensure the file exists
  #
  if (not -f "$filespec" ) {
    my $cwd = getcwd();
    $logger->logdie("CAN'T FIND FILE \'$filespec\' FROM $cwd");
  }

  #-------------------------------------------------------------------
  # Ensure the svn executable is executable
  #
  if (not -e $svn) {
    $logger->logdie("svn program $svn is not executable");
  }

  #-------------------------------------------------------------------
  # return if we already know the revision of this file
  #
  if ( $self->has_revision)
    {
      $logger->trace("already have revision");
      return 1;
    }

  #-------------------------------------------------------------------
  # Get SVN meta-data (revision, date, author)
  #
  my $info = eval { `$svn info \"$filespec\"` };

  #-------------------------------------------------------------------
  # Get the revision
  #
  if ($info =~ /Last\s+Changed\s+Rev:\s+(\d+)/) {
    $logger->trace("revision is $1");
    $self->set_revision($1);
  }
  else {
    $logger->warn("unknown SVN revision: $filespec");
  }

  #-------------------------------------------------------------------
  # Get the date
  #
  if ($info =~ /Last\s+Changed\s+Date:\s+(\d\d\d\d-\d\d-\d\d)/) {
    $logger->trace("date is $1");
    $self->set_date($1);
  }
  else {
    $logger->warn("unknown SVN date: $filespec");
  }

  #-------------------------------------------------------------------
  # Get the author
  #
  if ($info =~ /Last\s+Changed\s+Author:\s+(.*)/) {
    $logger->trace("author is $1");
    $self->set_author($1);
  }
  else {
    $logger->warn("unknown SVN author: $filespec");
  }

  #-------------------------------------------------------------------
  # Get SVN status (modified or not modified)
  #
  my $status = eval { `$svn status \"$filespec\"` };

  if ( $status =~ /^M/ )
    {
      $logger->warn("UNCOMMITTED CHANGES in $filespec");
      $self->set_has_been_modified(1);
    }

  #-------------------------------------------------------------------
  # Determine number of days since file last updated
  #
  if ( $self->has_date )
    {
      my $date = $self->get_date;

      my $last_changed_year  = '';
      my $last_changed_month = '';
      my $last_changed_day   = '';

      if ( $date =~ /^(\d\d\d\d)-(\d\d)-(\d\d)$/ )
	{
	  $last_changed_year  = $1;
	  $last_changed_month = $2;
	  $last_changed_day   = $3;

	  my ($this_year,$this_month,$this_day) = Date::Pcalc::Today();

	  my $days_old = Delta_Days
	    (
	     $last_changed_year,
	     $last_changed_month,
	     $last_changed_day,
	     $this_year,
	     $this_month,
	     $this_day
	    );

	  $self->set_days_old($days_old);
	}
      elsif ( $date ne 'unknown' )
	{
	  $logger->warn("UNEXPECTED DATE FORMAT \"$date\"");
	}
    }

  return;

  #-------------------------------------------------------------------
  # Notes
  #
  # This subroutine performs the function of gathering file meta-data
  # (version, author, date, and presence/absence of uncommitted
  # changes) from SVN.
  #
  # The presence of uncommitted changes in the containing document or
  # any of its included files makes the document MODIFIED.
  #
  # The structured manuscript language (SML) enables authors to add
  # inline comments that identify meta-data (version, author, date)
  # about external files.  For instance:
  #
  #     [#v:Solutions/ci-000001.txt:22]
  #
  #     include:$r22$: Solutions/ci-000001.txt
  #
  # is an inline comment that says the current version of the
  # Solutions/ci-000001.txt file is 22.
  #
  # This script automatically updates these inline comments to reflect
  # the current file meta-data.  It understands version, author, and
  # date as follows:
  #
  #     [#v:<path/to/filename>:<version>]
  #
  #     [#a:<path/to/filename>:<author>]
  #
  #     [#d:<path/to/filename>:<date>]
  #
  # This subroutine uses "svn info" and "svn status" to retrieve the
  # meta-data from the versioning system.  The text returned from the
  # "svn info" command looks like this:
  #
  #   g:/Engineering $ svn info Solutions/ci-000001.txt
  #   Path: Solutions\ci-000001.txt
  #   Name: ci-000001.txt
  #   URL: file:///G:/SVN%20Repository/Solutions/ci-000001.txt
  #   Repository Root: file:///G:/SVN%20Repository
  #   Repository UUID: 0169396a-9392-f34c-8026-a154977b8f00
  #   Revision: 21
  #   Node Kind: file
  #   Schedule: normal
  #   Last Changed Author: Don.Johnson
  #   Last Changed Rev: 19
  #   Last Changed Date: 2008-05-20 10:45:08 -0600 (Tue, 20 May 2008)
  #   Text Last Updated: 2008-05-20 11:45:52 -0600 (Tue, 20 May 2008)
  #   Checksum: 766ca7c11367ec7a8d9ee433d2de458c
  #
  #   g:/Engineering $
  #
  # When a file is in sync with the revision repository "svn status"
  # returns nothing.  When a file contains uncommitted changes, the
  # text returned from the "svn status" command looks like this (the
  # "M" is for modified):
  #
  #   M       publish-plan-semp.bat
  #
  #-------------------------------------------------------------------
  #   !!! bug here !!!
  #
  #   Sometimes I use the Perl packager (pp) to package this publish
  #   program into a windows executable.  But each time the program
  #   calls the "svn info" command, it launches a windows terminal
  #   window.  This slows down the program considerably and makes it
  #   unusable.  Look for another method for gathering SVN data about
  #   these files.
  #
  #-------------------------------------------------------------------
  #
  # The "revision" we want is the "Last Changed Rev:" 19 in the above
  # example.
  #
  # The "date" we want is the "Last Changed Date:" 2008-05-20 in the
  # above example.
  #
  # The "author" we want is the "Last Changed Author:" Don.Johnson in
  # the above example.
  #
  # The value of "modified" will be a boolean value of either 1 or 0.

}

######################################################################

sub _find_svn_executable {

  my $self = shift;

  if ( $^O eq 'MSWin32')
    {
      my $library = $self->get_library;
      my $options = $library->get_options;

      return $options->get_svn_executable;
    }

  elsif ( $^O eq 'linux' )
    {
      my $svn = `which svn`;

      $svn =~ s/[\r\n]*$//;
      # chomp($svn);

      if ($svn)
	{
	  return $svn;
	}

      else
	{
	  $logger->error("SVN EXECUTABLE NOT FOUND");
	  return 0;
	}
    }

  $logger->error("SVN EXECUTABLE NOT FOUND");
  return 0;
}

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
