#!/usr/bin/perl

# Copyright Tamil s.a.r.l. 2016
#
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

use Test::More tests => 28;
use DateTime;
use Test::MockModule;
use Test::Warn;
use XML::Simple;
use YAML;

use t::lib::Mocks;

use C4::Biblio;
use C4::Context;
use Koha::Database;

BEGIN {
    use_ok('Koha::OAI::Server::DeletedRecord');
    use_ok('Koha::OAI::Server::Description');
    use_ok('Koha::OAI::Server::GetRecord');
    use_ok('Koha::OAI::Server::Identify');
    use_ok('Koha::OAI::Server::ListBase');
    use_ok('Koha::OAI::Server::ListIdentifiers');
    use_ok('Koha::OAI::Server::ListMetadataFormats');
    use_ok('Koha::OAI::Server::ListRecords');
    use_ok('Koha::OAI::Server::ListSets');
    use_ok('Koha::OAI::Server::Record');
    use_ok('Koha::OAI::Server::Repository');
    use_ok('Koha::OAI::Server::ResumptionToken');
}

warn "HTTP::OAI version 4.03 or greater will make this test fail.\n".
     'Use the following command to downgrade: sudo cpanm HTTP::OAI@3.28'."\n".
     "https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17704"
	if $HTTP::OAI::VERSION > 3.28;

use constant NUMBER_OF_MARC_RECORDS => 10;

# Mocked CGI module in order to be able to send CGI parameters to OAI Server
my %param;
my $module = Test::MockModule->new('CGI');
$module->mock('Vars', sub { %param; });

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;

$dbh->do("SET time_zone='+00:00'");
$dbh->do('DELETE FROM issues');
$dbh->do('DELETE FROM biblio');
$dbh->do('DELETE FROM deletedbiblio');
$dbh->do('DELETE FROM deletedbiblioitems');
$dbh->do('DELETE FROM deleteditems');
$dbh->do('DELETE FROM oai_sets');

my $date_added = DateTime->now() . 'Z';
my $date_to = substr($date_added, 0, 10) . 'T23:59:59Z';
my (@header, @marcxml, @oaidc);
my $sth = $dbh->prepare('SELECT timestamp FROM biblioitems WHERE biblionumber=?');

# Add biblio records
foreach my $index ( 0 .. NUMBER_OF_MARC_RECORDS - 1 ) {
    my $record = MARC::Record->new();
    if (C4::Context->preference('marcflavour') eq 'UNIMARC') {
        $record->append_fields( MARC::Field->new('101', '', '', 'a' => "lng" ) );
        $record->append_fields( MARC::Field->new('200', '', '', 'a' => "Title $index" ) );
    } else {
        $record->append_fields( MARC::Field->new('008', '                                   lng' ) );
        $record->append_fields( MARC::Field->new('245', '', '', 'a' => "Title $index" ) );
    }
    my ($biblionumber) = AddBiblio($record, '');
    $sth->execute($biblionumber);
    my $timestamp = $sth->fetchrow_array . 'Z';
    $timestamp =~ s/ /T/;
    $timestamp = manipulate_timestamp( $index, $biblionumber, $timestamp );
    $record = GetMarcBiblio($biblionumber);
    $record = XMLin($record->as_xml_record);
    push @header, { datestamp => $timestamp, identifier => "TEST:$biblionumber" };
    push @oaidc, {
        header => $header[$index],
        metadata => {
            'oai_dc:dc' => {
                'dc:title' => "Title $index",
                'dc:language' => "lng",
                'dc:type' => {},
                'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
                'xmlns:oai_dc' => 'http://www.openarchives.org/OAI/2.0/oai_dc/',
                'xmlns:dc' => 'http://purl.org/dc/elements/1.1/',
                'xsi:schemaLocation' => 'http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd',
            },
        },
    };
    push @marcxml, {
        header => $header[$index],
        metadata => {
            record => $record,
        },
    };
}

my $syspref = {
    'LibraryName'           => 'My Library',
    'OAI::PMH'              => 1,
    'OAI-PMH:archiveID'     => 'TEST',
    'OAI-PMH:ConfFile'      => '',
    'OAI-PMH:MaxCount'      => 3,
    'OAI-PMH:DeletedRecord' => 'persistent',
};
while ( my ($name, $value) = each %$syspref ) {
    t::lib::Mocks::mock_preference( $name => $value );
}

sub test_query {
    my ($test, $param, $expected) = @_;

    %param = %$param;
    my %full_expected = (
        %$expected,
        (
            request      => 'http://localhost',
            xmlns        => 'http://www.openarchives.org/OAI/2.0/',
            'xmlns:xsi'  => 'http://www.w3.org/2001/XMLSchema-instance',
            'xsi:schemaLocation' => 'http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd',
        )
    );

    my $response;
    {
        my $stdout;
        local *STDOUT;
        open STDOUT, '>', \$stdout;
        Koha::OAI::Server::Repository->new();
        $response = XMLin($stdout);
    }

    delete $response->{responseDate};
    unless (is_deeply($response, \%full_expected, $test)) {
        diag
            "PARAM:" . Dump($param) .
            "EXPECTED:" . Dump(\%full_expected) .
            "RESPONSE:" . Dump($response);
    }
}

test_query('ListMetadataFormats', {verb => 'ListMetadataFormats'}, {
    ListMetadataFormats => {
        metadataFormat => [
            {
                metadataNamespace => 'http://www.openarchives.org/OAI/2.0/oai_dc/',
                metadataPrefix=> 'oai_dc',
                schema => 'http://www.openarchives.org/OAI/2.0/oai_dc.xsd',
            },
            {
                metadataNamespace => 'http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim',
                metadataPrefix => 'marc21',
                schema => 'http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd',
            },
            {
                metadataNamespace => 'http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim',
                metadataPrefix => 'marcxml',
                schema => 'http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd',
            },
        ],
    },
});

test_query('ListIdentifiers without metadataPrefix', {verb => 'ListIdentifiers'}, {
    error => {
        code => 'badArgument',
        content => "Required argument 'metadataPrefix' was undefined",
    },
});

test_query('ListIdentifiers', {verb => 'ListIdentifiers', metadataPrefix => 'marcxml'}, {
    ListIdentifiers => {
        header => [ @header[0..2] ],
        resumptionToken => {
            content => "marcxml/3/1970-01-01T00:00:00Z/$date_to//0/0",
            cursor  => 3,
        },
    },
});

test_query('ListIdentifiers', {verb => 'ListIdentifiers', metadataPrefix => 'marcxml'}, {
    ListIdentifiers => {
        header => [ @header[0..2] ],
        resumptionToken => {
            content => "marcxml/3/1970-01-01T00:00:00Z/$date_to//0/0",
            cursor  => 3,
        },
    },
});

test_query(
    'ListIdentifiers with resumptionToken 1',
    { verb => 'ListIdentifiers', resumptionToken => "marcxml/3/1970-01-01T00:00:00Z/$date_to//0/0" },
    {
        ListIdentifiers => {
            header => [ @header[3..5] ],
            resumptionToken => {
              content => "marcxml/6/1970-01-01T00:00:00Z/$date_to//0/0",
              cursor  => 6,
            },
          },
    },
);

test_query(
    'ListIdentifiers with resumptionToken 2',
    { verb => 'ListIdentifiers', resumptionToken => "marcxml/6/1970-01-01T00:00:00Z/$date_to//0/0" },
    {
        ListIdentifiers => {
            header => [ @header[6..8] ],
            resumptionToken => {
              content => "marcxml/9/1970-01-01T00:00:00Z/$date_to//0/0",
              cursor  => 9,
            },
          },
    },
);

test_query(
    'ListIdentifiers with resumptionToken 3, response without resumption',
    { verb => 'ListIdentifiers', resumptionToken => "marcxml/9/1970-01-01T00:00:00Z/$date_to//0/0" },
    {
        ListIdentifiers => {
            header => $header[9],
          },
    },
);

test_query('ListRecords marcxml without metadataPrefix', {verb => 'ListRecords'}, {
    error => {
        code => 'badArgument',
        content => "Required argument 'metadataPrefix' was undefined",
    },
});

test_query('ListRecords marcxml', {verb => 'ListRecords', metadataPrefix => 'marcxml'}, {
    ListRecords => {
        record => [ @marcxml[0..2] ],
        resumptionToken => {
          content => "marcxml/3/1970-01-01T00:00:00Z/$date_to//0/0",
          cursor  => 3,
        },
    },
});

test_query(
    'ListRecords marcxml with resumptionToken 1',
    { verb => 'ListRecords', resumptionToken => "marcxml/3/1970-01-01T00:00:00Z/$date_to//0/0" },
    { ListRecords => {
        record => [ @marcxml[3..5] ],
        resumptionToken => {
          content => "marcxml/6/1970-01-01T00:00:00Z/$date_to//0/0",
          cursor  => 6,
        },
    },
});

test_query(
    'ListRecords marcxml with resumptionToken 2',
    { verb => 'ListRecords', resumptionToken => "marcxml/6/1970-01-01T00:00:00Z/$date_to//0/0" },
    { ListRecords => {
        record => [ @marcxml[6..8] ],
        resumptionToken => {
          content => "marcxml/9/1970-01-01T00:00:00Z/$date_to//0/0",
          cursor  => 9,
        },
    },
});

# Last record, so no resumption token
test_query(
    'ListRecords marcxml with resumptionToken 3, response without resumption',
    { verb => 'ListRecords', resumptionToken => "marcxml/9/1970-01-01T00:00:00Z/$date_to//0/0" },
    { ListRecords => {
        record => $marcxml[9],
    },
});

test_query('ListRecords oai_dc', {verb => 'ListRecords', metadataPrefix => 'oai_dc'}, {
    ListRecords => {
        record => [ @oaidc[0..2] ],
        resumptionToken => {
          content => "oai_dc/3/1970-01-01T00:00:00Z/$date_to//0/0",
          cursor  => 3,
        },
    },
});

test_query(
    'ListRecords oai_dc with resumptionToken 1',
    { verb => 'ListRecords', resumptionToken => "oai_dc/3/1970-01-01T00:00:00Z/$date_to//0/0" },
    { ListRecords => {
        record => [ @oaidc[3..5] ],
        resumptionToken => {
          content => "oai_dc/6/1970-01-01T00:00:00Z/$date_to//0/0",
          cursor  => 6,
        },
    },
});

test_query(
    'ListRecords oai_dc with resumptionToken 2',
    { verb => 'ListRecords', resumptionToken => "oai_dc/6/1970-01-01T00:00:00Z/$date_to//0/0" },
    { ListRecords => {
        record => [ @oaidc[6..8] ],
        resumptionToken => {
          content => "oai_dc/9/1970-01-01T00:00:00Z/$date_to//0/0",
          cursor  => 9,
        },
    },
});

# Last record, so no resumption token
test_query(
    'ListRecords oai_dc with resumptionToken 3, response without resumption',
    { verb => 'ListRecords', resumptionToken => "oai_dc/9/1970-01-01T00:00:00Z/$date_to//0/0" },
    { ListRecords => {
        record => $oaidc[9],
    },
});

$schema->storage->txn_rollback;

sub manipulate_timestamp {
# This eliminates waiting a few seconds in order to get a higher timestamp
# Works only for 60 records..
    my ( $index, $bibno, $timestamp ) = @_;
    return $timestamp if $timestamp !~ /\d{2}Z/;
    my $secs = sprintf( "%02d", $index );
    $timestamp =~ s/\d{2}Z/${secs}Z/;
    $dbh->do("UPDATE biblioitems SET timestamp=? WHERE biblionumber=?", undef,
        ( $timestamp, $bibno ));
    return $timestamp;
}
