package Koha::Patrons;

# Copyright 2014 ByWater Solutions
# Copyright 2016 Koha Development Team
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;
use Scalar::Util qw(blessed);
use Try::Tiny;

use Carp;

use Koha::Database;
use Koha::DateUtils;

use Koha::ArticleRequests;
use Koha::ArticleRequest::Status;
use Koha::AuthUtils;
use Koha::Patron;

use Koha::Exception::UnknownObject;

use base qw(Koha::Objects);

=head1 NAME

Koha::Patron - Koha Patron Object class

=head1 API

=head2 Class Methods

=cut

sub _get_castable_unique_columns {
    return ['borrowernumber', 'cardnumber', 'userid'];
}

=head3 search_housebound_choosers

Returns all Patrons which are Housebound choosers.

=cut

sub search_housebound_choosers {
    my ( $self ) = @_;
    my $cho = $self->_resultset
        ->search_related('housebound_role', {
            housebound_chooser => 1,
        })->search_related('borrowernumber');
    return Koha::Patrons->_new_from_dbic($cho);
}

=head3 search_housebound_deliverers

Returns all Patrons which are Housebound deliverers.

=cut

sub search_housebound_deliverers {
    my ( $self ) = @_;
    my $del = $self->_resultset
        ->search_related('housebound_role', {
            housebound_deliverer => 1,
        })->search_related('borrowernumber');
    return Koha::Patrons->_new_from_dbic($del);
}

=head3 search_upcoming_membership_expires

my $patrons = Koha::Patrons->search_upcoming_membership_expires();

The 'before' and 'after' represent the number of days before/after the date
that is set by the preference MembershipExpiryDaysNotice.
If the pref is 14, before 2 and after 3 then you will get all expires
from 12 to 17 days.

=cut

sub search_upcoming_membership_expires {
    my ( $self, $params ) = @_;
    my $before = $params->{before} || 0;
    my $after  = $params->{after} || 0;
    delete $params->{before};
    delete $params->{after};

    my $days = C4::Context->preference("MembershipExpiryDaysNotice") || 0;
    my $date_before = dt_from_string->add( days => $days - $before );
    my $date_after = dt_from_string->add( days => $days + $after );
    my $dtf = Koha::Database->new->schema->storage->datetime_parser;

    $params->{dateexpiry} = {
        ">=" => $dtf->format_date( $date_before ),
        "<=" => $dtf->format_date( $date_after ),
    };
    return $self->SUPER::search(
        $params, { join => ['branchcode', 'categorycode'] }
    );
}

=head3 guarantor

Returns a Koha::Patron object for this borrower's guarantor

=cut

sub guarantor {
    my ( $self ) = @_;

    return Koha::Patrons->find( $self->guarantorid() );
}

=head3 search_patrons_to_anonymise

    my $patrons = Koha::Patrons->search_patrons_to_anonymise( { before => $older_than_date, [ library => $library ] } );

This method returns all patrons who has an issue history older than a given date.

=cut

sub search_patrons_to_anonymise {
    my ( $class, $params ) = @_;
    my $older_than_date = $params->{before};
    my $library         = $params->{library};
    $older_than_date = $older_than_date ? dt_from_string($older_than_date) : dt_from_string;
    $library ||=
      ( C4::Context->preference('IndependentBranches') && C4::Context->userenv && !C4::Context->IsSuperLibrarian() && C4::Context->userenv->{branch} )
      ? C4::Context->userenv->{branch}
      : undef;

    my $dtf = Koha::Database->new->schema->storage->datetime_parser;
    my $rs = $class->_resultset->search(
        {   returndate                  => { '<'   =>  $dtf->format_datetime($older_than_date), },
            'old_issues.borrowernumber' => { 'not' => undef },
            privacy                     => { '<>'  => 0 },                  # Keep forever
            ( $library ? ( 'old_issues.branchcode' => $library ) : () ),
        },
        {   join     => ["old_issues"],
            group_by => 'borrowernumber'
        }
    );
    return Koha::Patrons->_new_from_dbic($rs);
}

=head3 anonymise_issue_history

    Koha::Patrons->search->anonymise_issue_history( { [ before => $older_than_date ] } );

Anonymise issue history (old_issues) for all patrons older than the given date (optional).
To make sure all the conditions are met, the caller has the responsibility to
call search_patrons_to_anonymise to filter the Koha::Patrons set

=cut

sub anonymise_issue_history {
    my ( $self, $params ) = @_;

    my $older_than_date = $params->{before};

    $older_than_date = dt_from_string $older_than_date if $older_than_date;

    # The default of 0 does not work due to foreign key constraints
    # The anonymisation should not fail quietly if AnonymousPatron is not a valid entry
    # Set it to undef (NULL)
    my $dtf = Koha::Database->new->schema->storage->datetime_parser;
    my $old_issues_to_anonymise = $self->search_related(
        'old_issues',
        {
            (
                $older_than_date
                ? ( returndate =>
                      { '<' => $dtf->format_datetime($older_than_date) } )
                : ()
            )
        }
    );
    my $anonymous_patron = C4::Context->preference('AnonymousPatron') || undef;
    $old_issues_to_anonymise->update( { 'old_issues.borrowernumber' => $anonymous_patron } );
}

=head3 type

=cut

sub _type {
    return 'Borrower';
}

sub object_class {
    return 'Koha::Patron';
}

=head cast

    my $borrower = Koha::Patrons->cast('cardnumber');
    my $borrower = Koha::Patrons->cast($Koha::Patron);
    my $borrower = Koha::Patrons->cast('userid');
    my $borrower = Koha::Patrons->cast('borrowernumber');
    my $borrower = Koha::Patrons->cast({borrowernumber => 123,
                                                });
    my $borrower = Koha::Patrons->cast({firstname => 'Olli-Antti',
                                                    surname => 'Kivi',
                                                    address => 'Koskikatu 25',
                                                });

Because there are gazillion million ways in Koha to invoke a Borrower, this is a
omnibus for easily creating a Borrower-object from all the arcane invocations present
in many parts of Koha.
Just throw the crazy and unpredictable return values from myriad subroutines returning
some kind of an borrowerish value to this casting function to get a brand new Koha::Patron.
@PARAM1 Scalar, or HASHRef.
@RETURNS Koha::Patron, possibly already in DB or a completely new one if nothing was
                         inferred from the DB.
@THROWS Koha::Exception::BadParameter, if no idea what to do with the input.
@THROWS Koha::Exception::UnknownObject, if we cannot find a Borrower with the given input.
=cut

sub cast {
    my ($class, $input) = @_;

    my $borrower;
    try {
        $borrower = $class->SUPER::cast($input);
    } catch {
        if (blessed($_) && $_->isa('Koha::Exception::UnknownObject')) {
            $borrower = Koha::AuthUtils::checkKohaSuperuserFromUserid($input);
            unless ($borrower) {
                $_->rethrow();
            }
        }
        else {
            die $_;
        }
    };

    return $borrower;
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
