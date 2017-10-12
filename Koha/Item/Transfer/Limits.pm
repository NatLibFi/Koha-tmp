package Koha::Item::Transfer::Limits;

# Copyright Koha-Suomi Oy 2017
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

use Koha::Database;

use Koha::Item::Transfer::Limit;

use base qw(Koha::Objects);

=head1 NAME

Koha::Item::Transfer::Limits - Koha Item Transfer Limits Object set class

=head1 API

=head2 Class Methods

=cut

=head3 type

=cut

sub _type {
    return 'BranchTransferLimit';
}

sub object_class {
    return 'Koha::Item::Transfer::Limit';
}

1;
