#!/usr/bin/perl

# Copyright KohaSuomi 2016
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
#

use Modern::Perl;
use Test::More;

use Koha::Patrons;
use t::lib::TestObjects::MessageQueueFactory;
use C4::Letters;

my $subtestContext = {};

#Check if the precondition Borrower exists, it shouldn't
my $borrower = Koha::Patrons->find({cardnumber => '1A23' });
ok(not(defined($borrower)), "MessageQueue borrower not defined");

#Create the MessageQueue
my $messages = t::lib::TestObjects::MessageQueueFactory->createTestGroup([{
    subject => "The quick brown fox",
    content => "Jumps over the lazy dog.",
    cardnumber => '1A23',
    message_transport_type => 'sms',
    from_address => '11A001@example.com',
},

    ], undef, $subtestContext);

#Check if the previously non-existent Borrower is now autogenerated?
ok($borrower = Koha::Patrons->find({cardnumber => '1A23' }),
  'MessageQueue borrower autogenerated');
ok(ref($borrower) eq 'Koha::Patron', "MessageQueue borrower is a Koha::Object subclass");

# check that the message exists in queue
my $queued_messages = C4::Letters->_get_unsent_messages();

my $found_testMessage = 0;
foreach my $message (@$queued_messages){
    if ($message->{from_address} eq '11A001@example.com'){
        $found_testMessage = 1;
        last;
    }
}

ok($found_testMessage, 'MessageQueue \'11A001@example.com\', message_queue match.');

# delete the queued message
t::lib::TestObjects::ObjectFactory->tearDownTestContext($subtestContext);

# confirm the deletion
$queued_messages = C4::Letters->_get_unsent_messages();

$found_testMessage = 0;
foreach my $message (@$queued_messages){
    if ($message->{from_address} eq '11A001@example.com'){
        $found_testMessage = 1;
        last;
    }
}

is($found_testMessage, 0, 'MessageQueue \'11A001@example.com\', deleted.');

done_testing();
