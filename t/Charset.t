#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 17;
use Encode qw( is_utf8 );

use MARC::Record;

use t::lib::Mocks;

use utf8;
use open ':std', ':encoding(utf8)';

BEGIN {
    use_ok('C4::Charset');
}

my $string;
ok(!defined(NormalizeString($string,undef,1)),'Uninitialized string case 1 normalizes to uninitialized string.');

$string = 'Sample';
ok(defined(NormalizeString($string,undef,0)), 'Initialized string case 1 normalizes to some string.');
ok(defined(NormalizeString($string,undef,1)), 'Initialized string case 2 normalizes to some string.');
ok(defined(NormalizeString($string,1,0)),     'Initialized string case 3 normalizes to some string.');
ok(defined(NormalizeString($string,1,1)),     'Initialized string case 4 normalizes to some string.');

my $octets = "abc";
ok(IsStringUTF8ish($octets), "verify octets are valid UTF-8 (ASCII)");

$octets = "flamb\xc3\xa9";
ok(!Encode::is_utf8($octets), "verify that string does not have Perl UTF-8 flag on");
ok(IsStringUTF8ish($octets), "verify octets are valid UTF-8 (LATIN SMALL LETTER E WITH ACUTE)");
ok(!Encode::is_utf8($octets), "verify that IsStringUTF8ish does not magically turn Perl UTF-8 flag on");

$octets = "a\xc2" . "c";
ok(!IsStringUTF8ish($octets), "verify octets are not valid UTF-8");

ok( !SetUTF8Flag(), 'SetUTF8Flag returns undef if no record passed' );

my $record = MARC::Record->new();
ok( !SetUTF8Flag($record), 'SetUTF8Flag returns undef if the record has no subfields' );
# Add some fields/subfields
$record->append_fields(
    MARC::Field->new('100', ' ', ' ', a => 'Julio Cortazar'),
    MARC::Field->new('245', ' ', ' ', a => 'Rayuela'),
);
# Verify our data serves its purpose
ok( !Encode::is_utf8($record->subfield('100','a')) &&
    !Encode::is_utf8($record->subfield('245','a')),
    'Verify that the subfields are NOT set the UTF-8 flag yet' );

SetUTF8Flag($record);

ok( Encode::is_utf8($record->subfield('100','a')) &&
    Encode::is_utf8($record->subfield('245','a')),
    'SetUTF8Flag sets the UTF-8 flag to all subfields' );

is( nsb_clean("Le Moyen Âge"), "Le Moyen Âge", "nsb_clean removes  and " );

subtest 'SetMarcUnicodeFlag' => sub {
    plan tests => 2;
    # TODO This should be done in MARC::Record
    my $leader                  = '012345678X0             ';
    my $expected_marc21_leader  = '012345678a0             '; # position 9 of leader must be 'a'
    my $expected_unimarc_leader = '012345678X0             '; # position 9 of leader must not be changed
    # Note that position 9 of leader should be blank for UNIMARC, but as it is not related to encoding
    # we do not want to change it

    t::lib::Mocks::mock_preference( 'marcflavour', 'MARC21' );
    my $marc21_record = MARC::Record->new;
    $marc21_record->leader($leader);
    SetMarcUnicodeFlag( $marc21_record, C4::Context->preference('marcflavour') );
    is( $marc21_record->leader, $expected_marc21_leader, 'Leader 9 for MARC21 mush be "a"' );

    t::lib::Mocks::mock_preference( 'marcflavour',             'UNIMARC' );
    t::lib::Mocks::mock_preference( 'UNIMARCField100Language', 'fre' );
    my $unimarc_record = MARC::Record->new;
    $unimarc_record->leader($leader);
    SetMarcUnicodeFlag( $unimarc_record, C4::Context->preference('marcflavour') );
    is( $unimarc_record->leader, $expected_unimarc_leader, 'Leader 9 for UNIMARC must be blank' );
};

1;
