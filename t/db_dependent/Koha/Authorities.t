#!/usr/bin/perl

# Copyright 2015 Koha Development team
#
# This file is part of Koha
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

use Test::More tests => 6;
use MARC::Field;
use MARC::File::XML;
use MARC::Record;
use Test::Deep;
use Test::MockModule;
use Test::MockObject;
use Test::Warn;

use C4::Context;
use Koha::Authority;
use Koha::Authorities;
use Koha::Authority::MergeRequest;
use Koha::Authority::Type;
use Koha::Authority::Types;
use Koha::Database;

use t::lib::Mocks;
use t::lib::TestBuilder;

BEGIN {
    #TODO Helpful as long as we have issues here
    my $mock = Test::MockObject->new();
    $mock->fake_module( 'Catmandu::Store::ElasticSearch' );
}

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

# Globals
our $search_compat_pars;
our $builder              = t::lib::TestBuilder->new;

my $nb_of_authorities     = Koha::Authorities->search->count;
my $nb_of_authority_types = Koha::Authority::Types->search->count;
my $new_authority_type_1  = Koha::Authority::Type->new(
    {   authtypecode       => 'my_ac_1',
        authtypetext       => 'my authority type text 1',
        auth_tag_to_report => '100',
        summary            => 'my summary for authority 1',
    }
)->store;
my $new_authority_1 = Koha::Authority->new( { authtypecode => $new_authority_type_1->authtypecode, } )->store;
my $new_authority_2 = Koha::Authority->new( { authtypecode => $new_authority_type_1->authtypecode, } )->store;

is( Koha::Authority::Types->search->count, $nb_of_authority_types + 1, 'The authority type should have been added' );
is( Koha::Authorities->search->count,      $nb_of_authorities + 2,     'The 2 authorities should have been added' );

$new_authority_1->delete;
is( Koha::Authorities->search->count, $nb_of_authorities + 1, 'Delete should have deleted the authority' );

subtest 'New merge request, method oldmarc' => sub {
    plan tests => 4;

    my $marc = MARC::Record->new;
    $marc->append_fields(
        MARC::Field->new( '100', '', '', a => 'a', b => 'b_findme' ),
        MARC::Field->new( '200', '', '', a => 'aa' ),
    );
    my $req = Koha::Authority::MergeRequest->new({
        authid => $new_authority_2->authid,
        reportxml => 'Should be discarded',
    });
    is( $req->reportxml, undef, 'Reportxml is undef without oldrecord' );

    $req = Koha::Authority::MergeRequest->new({
        authid => $new_authority_2->authid,
        oldrecord => $marc,
    });
    like( $req->reportxml, qr/b_findme/, 'Reportxml initialized' );

    # Check if oldmarc is a MARC::Record and has one or two fields
    is( ref( $req->oldmarc ), 'MARC::Record', 'Check oldmarc method' );
    if( C4::Context->preference('marcflavour') eq 'UNIMARC' ) {
        is( scalar $req->oldmarc->fields, 2, 'UNIMARC contains two fields' );
    } else {
        is( scalar $req->oldmarc->fields, 1, 'MARC21 contains one field' );
    }
};

subtest 'Testing reporting_tag_xml in MergeRequest' => sub {
    plan tests => 2;

    my $record = MARC::Record->new;
    $record->append_fields(
        MARC::Field->new( '024', '', '', a => 'aaa' ),
        MARC::Field->new( '110', '', '', a => 'Best author' ),
        MARC::Field->new( '234', '', '', a => 'Just a field' ),
    );
    my $xml = Koha::Authority::MergeRequest->reporting_tag_xml({
        record => $record, tag => '100',
    });
    is( $xml, undef, 'Expected no result for wrong tag' );
    $xml = Koha::Authority::MergeRequest->reporting_tag_xml({
        record => $record, tag => '110',
    });
    my $newrecord = MARC::Record->new_from_xml(
        $xml, 'UTF-8',
        C4::Context->preference('marcflavour') eq 'UNIMARC' ?
        'UNIMARCAUTH' :
        'MARC21',
    );
    cmp_deeply( $record->field('110')->subfields,
        $newrecord->field('110')->subfields,
        'Compare reporting tag in both records',
    );
};

subtest 'Trivial tests for get_count_usage and linked_biblionumbers' => sub {
    plan tests => 5;

    # NOTE: We are not testing $searcher->simple_search_compat here. Suppose
    # that should be done in t/db../Koha/SearchEngine?
    # So we're just testing the 'wrapper' here.

    my ( $mods, $koha_fields );
    t::lib::Mocks::mock_preference('SearchEngine', 'Zebra');
    $mods->{zebra} = Test::MockModule->new( 'Koha::SearchEngine::Zebra::Search' );
    $mods->{elastic} = Test::MockModule->new( 'Koha::SearchEngine::Elasticsearch::Search' );
    $mods->{biblio} = Test::MockModule->new( 'C4::Biblio' );
    $mods->{zebra}->mock( 'simple_search_compat', \&simple_search_compat );
    $mods->{elastic}->mock( 'simple_search_compat', \&simple_search_compat );
    $mods->{biblio}->mock( 'GetMarcFromKohaField', sub { return @$koha_fields; });

    my $auth1 = $builder->build({ source => 'AuthHeader' });
    $auth1 = Koha::Authorities->find( $auth1->{authid} );

    # Test error condition
    my $count;
    $search_compat_pars = [ 0, 'some_error' ];
    warning_like { $count = $auth1->get_usage_count }
        qr/some_error/, 'Catch warn of simple_search_compat';
    is( $count, undef, 'Undef returned when error encountered' );

    # Simple test with some results; one result discarded in the 2nd test
    $search_compat_pars = [ 1 ];
    $koha_fields = [ '001', '' ];
    is(  $auth1->get_usage_count, 3, 'Three results expected (Zebra)' );
    cmp_deeply( [ $auth1->linked_biblionumbers ], [ 1001, 3003 ],
        'linked_biblionumbers should ignore record without biblionumber' );

    # And a simple test with Elastic
    t::lib::Mocks::mock_preference('SearchEngine', 'Elasticsearch');
    cmp_deeply( [ $auth1->linked_biblionumbers ], [ 2001 ],
        'linked_biblionumbers with Elasticsearch' );
};

sub simple_search_compat {
    if( $search_compat_pars->[0] == 0 ) {
        return ( $search_compat_pars->[1], [], 0 );
    } elsif( $search_compat_pars->[0] == 1 ) {
        my $records = C4::Context->preference('SearchEngine') eq 'Zebra'
            ? few_marcxml_records()
            : few_marc_records();
        return ( undef, $records, scalar @$records );
    }
}

sub few_marcxml_records {
    return [
q|<?xml version="1.0" encoding="UTF-8"?>
<record xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.loc.gov/MARC21/slim" xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">
    <controlfield tag="001">1001</controlfield>
    <datafield tag="110" ind1=" " ind2=" ">
        <subfield code="9">102</subfield>
        <subfield code="a">My Corporation</subfield>
    </datafield>
</record>|,
q|<?xml version="1.0" encoding="UTF-8"?>
<record xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.loc.gov/MARC21/slim" xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">
    <!-- No biblionumber here -->
    <datafield tag="610" ind1=" " ind2=" ">
        <subfield code="9">112</subfield>
        <subfield code="a">Another Corporation</subfield>
    </datafield>
</record>|,
q|<?xml version="1.0" encoding="UTF-8"?>
<record xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.loc.gov/MARC21/slim" xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">
    <controlfield tag="001">3003</controlfield>
    <datafield tag="110" ind1=" " ind2=" ">
        <subfield code="9">102</subfield>
        <subfield code="a">My Corporation</subfield>
    </datafield>
</record>|
    ];
}

sub few_marc_records {
    my $marc = MARC::Record->new;
    $marc->append_fields(
        MARC::Field->new( '001', '2001' ),
        MARC::Field->new( '245', '', '', a => 'Title' ),
    );
    return [ $marc ];
}

$schema->storage->txn_rollback;
