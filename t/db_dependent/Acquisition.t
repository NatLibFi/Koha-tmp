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

use POSIX qw(strftime);

use Test::More tests => 65;
use Koha::Database;

BEGIN {
    use_ok('C4::Acquisition');
    use_ok('C4::Biblio');
    use_ok('C4::Budgets');
    use_ok('Koha::Acquisition::Order');
    use_ok('Koha::Acquisition::Booksellers');
}

# Sub used for testing C4::Acquisition subs returning order(s):
#    GetOrdersByStatus, GetOrders, GetDeletedOrders, GetOrder etc.
# (\@test_missing_fields,\@test_extra_fields,\@test_different_fields,$test_nbr_fields) =
#  _check_fields_of_order ($exp_fields, $original_order_content, $order_to_check);
# params :
# $exp_fields             : arrayref whose elements are the keys we expect to find
# $original_order_content : hashref whose 2 keys str and num contains hashrefs
#                           containing content fields of the order created with Koha::Acquisition::Order
# $order_to_check         : hashref whose keys/values are the content of an order
#                           returned by the C4::Acquisition sub we are testing
# returns :
# \@test_missing_fields   : arrayref void if ok ; otherwise contains the list of
#                           fields missing in $order_to_check
# \@test_extra_fields     : arrayref void if ok ; otherwise contains the list of
#                           fields unexpected in $order_to_check
# \@test_different_fields : arrayref void if ok ; otherwise contains the list of
#                           fields which value is not the same in between $order_to_check and
# $test_nbr_fields        : contains the number of fields of $order_to_check

sub _check_fields_of_order {
    my ( $exp_fields, $original_order_content, $order_to_check ) = @_;
    my @test_missing_fields   = ();
    my @test_extra_fields     = ();
    my @test_different_fields = ();
    my $test_nbr_fields       = scalar( keys %$order_to_check );
    foreach my $field (@$exp_fields) {
        push @test_missing_fields, $field
          unless exists( $order_to_check->{$field} );
    }
    foreach my $field ( keys %$order_to_check ) {
        push @test_extra_fields, $field
          unless grep ( /^$field$/, @$exp_fields );
    }
    foreach my $field ( keys %{ $original_order_content->{str} } ) {
        push @test_different_fields, $field
          unless ( !exists $order_to_check->{$field} )
          or ( $original_order_content->{str}->{$field} eq
            $order_to_check->{$field} );
    }
    foreach my $field ( keys %{ $original_order_content->{num} } ) {
        push @test_different_fields, $field
          unless ( !exists $order_to_check->{$field} )
          or ( $original_order_content->{num}->{$field} ==
            $order_to_check->{$field} );
    }
    return (
        \@test_missing_fields,   \@test_extra_fields,
        \@test_different_fields, $test_nbr_fields
    );
}

# Sub used for testing C4::Acquisition subs returning several orders
# (\@test_missing_fields,\@test_extra_fields,\@test_different_fields,\@test_nbr_fields) =
#   _check_fields_of_orders ($exp_fields, $original_orders_content, $orders_to_check)
sub _check_fields_of_orders {
    my ( $exp_fields, $original_orders_content, $orders_to_check ) = @_;
    my @test_missing_fields   = ();
    my @test_extra_fields     = ();
    my @test_different_fields = ();
    my @test_nbr_fields       = ();
    foreach my $order_to_check (@$orders_to_check) {
        my $original_order_content =
          ( grep { $_->{str}->{ordernumber} eq $order_to_check->{ordernumber} }
              @$original_orders_content )[0];
        my (
            $t_missing_fields,   $t_extra_fields,
            $t_different_fields, $t_nbr_fields
          )
          = _check_fields_of_order( $exp_fields, $original_order_content,
            $order_to_check );
        push @test_missing_fields,   @$t_missing_fields;
        push @test_extra_fields,     @$t_extra_fields;
        push @test_different_fields, @$t_different_fields;
        push @test_nbr_fields,       $t_nbr_fields;
    }
    @test_missing_fields = keys %{ { map { $_ => 1 } @test_missing_fields } };
    @test_extra_fields   = keys %{ { map { $_ => 1 } @test_extra_fields } };
    @test_different_fields =
      keys %{ { map { $_ => 1 } @test_different_fields } };
    return (
        \@test_missing_fields,   \@test_extra_fields,
        \@test_different_fields, \@test_nbr_fields
    );
}


my $schema = Koha::Database->new()->schema();
$schema->storage->txn_begin();

my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;

# Creating some orders
my $bookseller = Koha::Acquisition::Bookseller->new(
    {
        name         => "my vendor",
        address1     => "bookseller's address",
        phone        => "0123456",
        active       => 1,
        deliverytime => 5,
    }
)->store;
my $booksellerid = $bookseller->id;

my $booksellerinfo = Koha::Acquisition::Booksellers->find( $booksellerid );
is( $booksellerinfo->deliverytime,
    5, 'set deliverytime when creating vendor (Bug 10556)' );

my ( $basket, $basketno );
ok(
    $basketno = NewBasket( $booksellerid, 1 ),
    "NewBasket(  $booksellerid , 1  ) returns $basketno"
);
ok( $basket = GetBasket($basketno), "GetBasket($basketno) returns $basket" );

my $bpid=AddBudgetPeriod({
        budget_period_startdate => '2008-01-01'
        , budget_period_enddate => '2008-12-31'
        , budget_period_active  => 1
        , budget_period_description    => "MAPERI"
});

my $budgetid = C4::Budgets::AddBudget(
    {
        budget_code => "budget_code_test_getordersbybib",
        budget_name => "budget_name_test_getordersbybib",
        budget_period_id => $bpid,
    }
);
my $budget = C4::Budgets::GetBudget($budgetid);

my @ordernumbers;
my ( $biblionumber1, $biblioitemnumber1 ) = AddBiblio( MARC::Record->new, '' );
my ( $biblionumber2, $biblioitemnumber2 ) = AddBiblio( MARC::Record->new, '' );
my ( $biblionumber3, $biblioitemnumber3 ) = AddBiblio( MARC::Record->new, '' );
my ( $biblionumber4, $biblioitemnumber4 ) = AddBiblio( MARC::Record->new, '' );
my ( $biblionumber5, $biblioitemnumber5 ) = AddBiblio( MARC::Record->new, '' );

# Prepare 5 orders, and make distinction beween fields to be tested with eq and with ==
# Ex : a price of 50.1 will be stored internally as 5.100000

my @order_content = (
    {
        str => {
            basketno       => $basketno,
            biblionumber   => $biblionumber1,
            budget_id      => $budget->{budget_id},
            uncertainprice => 0,
            order_internalnote => "internal note",
            order_vendornote   => "vendor note",
            ordernumber => '',
        },
        num => {
            quantity  => 24,
            listprice => 50.121111,
            ecost     => 38.15,
            rrp       => 40.15,
            discount  => 5.1111,
            tax_rate   => 0.0515
        }
    },
    {
        str => {
            basketno     => $basketno,
            biblionumber => $biblionumber2,
            budget_id    => $budget->{budget_id}
        },
        num => { quantity => 42 }
    },
    {
        str => {
            basketno       => $basketno,
            biblionumber   => $biblionumber2,
            budget_id      => $budget->{budget_id},
            uncertainprice => 0,
            order_internalnote => "internal note",
            order_vendornote   => "vendor note"
        },
        num => {
            quantity  => 4,
            ecost     => 42.1,
            rrp       => 42.1,
            listprice => 10.1,
            ecost     => 38.1,
            rrp       => 11.0,
            discount  => 5.1,
            tax_rate   => 0.1
        }
    },
    {
        str => {
            basketno     => $basketno,
            biblionumber => $biblionumber3,
            budget_id    => $budget->{budget_id},
            order_internalnote => "internal note",
            order_vendornote   => "vendor note"
        },
        num => {
            quantity       => 4,
            ecost          => 40,
            rrp            => 42,
            listprice      => 10,
            ecost          => 38.15,
            rrp            => 11.00,
            discount       => 0,
            uncertainprice => 0,
            tax_rate        => 0
        }
    },
    {
        str => {
            basketno     => $basketno,
            biblionumber => $biblionumber4,
            budget_id    => $budget->{budget_id},
            order_internalnote => "internal note",
            order_vendornote   => "vendor note"
        },
        num => {
            quantity       => 1,
            ecost          => 10,
            rrp            => 10,
            listprice      => 10,
            ecost          => 10,
            rrp            => 10,
            discount       => 0,
            uncertainprice => 0,
            tax_rate        => 0
        }
    },
    {
        str => {
            basketno     => $basketno,
            biblionumber => $biblionumber5,
            budget_id    => $budget->{budget_id},
            order_internalnote => "internal note",
            order_vendornote   => "vendor note"
        },
        num => {
            quantity       => 1,
            ecost          => 10,
            rrp            => 10,
            listprice      => 10,
            ecost          => 10,
            rrp            => 10,
            discount       => 0,
            uncertainprice => 0,
            tax_rate        => 0
        }
    }
);

# Create 5 orders in database
for ( 0 .. 5 ) {
    my %ocontent;
    @ocontent{ keys %{ $order_content[$_]->{num} } } =
      values %{ $order_content[$_]->{num} };
    @ocontent{ keys %{ $order_content[$_]->{str} } } =
      values %{ $order_content[$_]->{str} };
    $ordernumbers[$_] = Koha::Acquisition::Order->new( \%ocontent )->insert->{ordernumber};
    $order_content[$_]->{str}->{ordernumber} = $ordernumbers[$_];
}

DelOrder( $order_content[3]->{str}->{biblionumber}, $ordernumbers[3] );

my $invoiceid = AddInvoice(
    invoicenumber => 'invoice',
    booksellerid  => $booksellerid,
    unknown       => "unknown"
);

my $invoice = GetInvoice( $invoiceid );

my ($datereceived, $new_ordernumber) = ModReceiveOrder(
    {
        biblionumber      => $biblionumber4,
        order             => GetOrder( $ordernumbers[4] ),
        quantityreceived  => 1,
        invoice           => $invoice,
        budget_id          => $order_content[4]->{str}->{budget_id},
    }
);

my $search_orders = SearchOrders({
    booksellerid => $booksellerid,
    basketno     => $basketno
});
isa_ok( $search_orders, 'ARRAY' );
ok(
    (
        ( scalar @$search_orders == 5 )
          and !grep ( $_->{ordernumber} eq $ordernumbers[3], @$search_orders )
    ),
    "SearchOrders only gets non-cancelled orders"
);

$search_orders = SearchOrders({
    booksellerid => $booksellerid,
    basketno     => $basketno,
    pending      => 1
});
ok(
    (
        ( scalar @$search_orders == 4 ) and !grep ( (
                     ( $_->{ordernumber} eq $ordernumbers[3] )
                  or ( $_->{ordernumber} eq $ordernumbers[4] )
            ),
            @$search_orders )
    ),
    "SearchOrders with pending params gets only pending orders (bug 10723)"
);

$search_orders = SearchOrders({
    booksellerid => $booksellerid,
    basketno     => $basketno,
    pending      => 1,
    ordered      => 1,
});
is( scalar (@$search_orders), 0, "SearchOrders with pending and ordered params gets only pending ordered orders (bug 11170)" );

$search_orders = SearchOrders({
    ordernumber => $ordernumbers[4]
});
is( scalar (@$search_orders), 1, "SearchOrders takes into account the ordernumber filter" );

$search_orders = SearchOrders({
    biblionumber => $biblionumber4
});
is( scalar (@$search_orders), 1, "SearchOrders takes into account the biblionumber filter" );

$search_orders = SearchOrders({
    biblionumber => $biblionumber4,
    pending      => 1
});
is( scalar (@$search_orders), 0, "SearchOrders takes into account the biblionumber and pending filters" );

#
# Test GetBudgetByOrderNumber
#
ok( GetBudgetByOrderNumber( $ordernumbers[0] )->{'budget_id'} eq $budgetid,
    "GetBudgetByOrderNumber returns expected budget" );

my @lateorders = GetLateOrders(0);
is( scalar grep ( $_->{basketno} eq $basketno, @lateorders ),
    0, "GetLateOrders does not get orders from opened baskets" );
C4::Acquisition::CloseBasket($basketno);
@lateorders = GetLateOrders(0);
isnt( scalar grep ( $_->{basketno} eq $basketno, @lateorders ),
    0, "GetLateOrders gets orders from closed baskets" );
ok( !grep ( $_->{ordernumber} eq $ordernumbers[3], @lateorders ),
    "GetLateOrders does not get cancelled orders" );
ok( !grep ( $_->{ordernumber} eq $ordernumbers[4], @lateorders ),
    "GetLateOrders does not get received orders" );

$search_orders = SearchOrders({
    booksellerid => $booksellerid,
    basketno     => $basketno,
    pending      => 1,
    ordered      => 1,
});
is( scalar (@$search_orders), 4, "SearchOrders with pending and ordered params gets only pending ordered orders. After closing the basket, orders are marked as 'ordered' (bug 11170)" );

#
# Test AddClaim
#

my $order = $lateorders[0];
AddClaim( $order->{ordernumber} );
my $neworder = GetOrder( $order->{ordernumber} );
is(
    $neworder->{claimed_date},
    strftime( "%Y-%m-%d", localtime(time) ),
    "AddClaim : Check claimed_date"
);

my $order2 = GetOrder( $ordernumbers[1] );
$order2->{order_internalnote} = "my notes";
( $datereceived, $new_ordernumber ) = ModReceiveOrder(
    {
        biblionumber     => $biblionumber2,
        order            => $order2,
        quantityreceived => 2,
        invoice          => $invoice,
    }
)
;
$order2 = GetOrder( $ordernumbers[1] );
is( $order2->{'quantityreceived'},
    0, 'Splitting up order did not receive any on original order' );
is( $order2->{'quantity'}, 40, '40 items on original order' );
is( $order2->{'budget_id'}, $budgetid,
    'Budget on original order is unchanged' );
is( $order2->{order_internalnote}, "my notes",
    'ModReceiveOrder and GetOrder deal with internal notes' );

$neworder = GetOrder($new_ordernumber);
is( $neworder->{'quantity'}, 2, '2 items on new order' );
is( $neworder->{'quantityreceived'},
    2, 'Splitting up order received items on new order' );
is( $neworder->{'budget_id'}, $budgetid, 'Budget on new order is unchanged' );

is( $neworder->{ordernumber}, $new_ordernumber, 'Split: test ordernumber' );
is( $neworder->{parent_ordernumber}, $ordernumbers[1], 'Split: test parent_ordernumber' );

my $orders = GetHistory( ordernumber => $ordernumbers[1] );
is( scalar( @$orders ), 1, 'GetHistory with a given ordernumber returns 1 order' );
$orders = GetHistory( ordernumber => $ordernumbers[1], search_children_too => 1 );
is( scalar( @$orders ), 2, 'GetHistory with a given ordernumber and search_children_too set returns 2 orders' );

my $budgetid2 = C4::Budgets::AddBudget(
    {
        budget_code => "budget_code_test_modrecv",
        budget_name => "budget_name_test_modrecv",
    }
);

my $order3 = GetOrder( $ordernumbers[2] );
$order3->{order_internalnote} = "my other notes";
( $datereceived, $new_ordernumber ) = ModReceiveOrder(
    {
        biblionumber     => $biblionumber2,
        order            => $order3,
        quantityreceived => 2,
        invoice          => $invoice,
        budget_id        => $budgetid2,
    }
);

$order3 = GetOrder( $ordernumbers[2] );
is( $order3->{'quantityreceived'},
    0, 'Splitting up order did not receive any on original order' );
is( $order3->{'quantity'}, 2, '2 items on original order' );
is( $order3->{'budget_id'}, $budgetid,
    'Budget on original order is unchanged' );
is( $order3->{order_internalnote}, "my other notes",
    'ModReceiveOrder and GetOrder deal with notes' );

$neworder = GetOrder($new_ordernumber);
is( $neworder->{'quantity'}, 2, '2 items on new order' );
is( $neworder->{'quantityreceived'},
    2, 'Splitting up order received items on new order' );
is( $neworder->{'budget_id'}, $budgetid2, 'Budget on new order is changed' );

$order3 = GetOrder( $ordernumbers[2] );
$order3->{order_internalnote} = "my third notes";
( $datereceived, $new_ordernumber ) = ModReceiveOrder(
    {
        biblionumber     => $biblionumber2,
        order            => $order3,
        quantityreceived => 2,
        invoice          => $invoice,
        budget_id        => $budgetid2,
    }
);

$order3 = GetOrder( $ordernumbers[2] );
is( $order3->{'quantityreceived'}, 2,          'Order not split up' );
is( $order3->{'quantity'},         2,          '2 items on order' );
is( $order3->{'budget_id'},        $budgetid2, 'Budget has changed' );
is( $order3->{order_internalnote}, "my third notes", 'ModReceiveOrder and GetOrder deal with notes' );

my $nonexistent_order = GetOrder();
is( $nonexistent_order, undef, 'GetOrder returns undef if no ordernumber is given' );
$nonexistent_order = GetOrder( 424242424242 );
is( $nonexistent_order, undef, 'GetOrder returns undef if a nonexistent ordernumber is given' );

# Tests for DelOrder
my $order1 = GetOrder($ordernumbers[0]);
my $error = DelOrder($order1->{biblionumber}, $order1->{ordernumber});
ok((not defined $error), "DelOrder does not fail");
$order1 = GetOrder($order1->{ordernumber});
ok((defined $order1->{datecancellationprinted}), "order is cancelled");
ok((not defined $order1->{cancellationreason}), "order has no cancellation reason");
ok((defined GetBiblio($order1->{biblionumber})), "biblio still exists");

$order2 = GetOrder($ordernumbers[1]);
$error = DelOrder($order2->{biblionumber}, $order2->{ordernumber}, 1);
ok((not defined $error), "DelOrder does not fail");
$order2 = GetOrder($order2->{ordernumber});
ok((defined $order2->{datecancellationprinted}), "order is cancelled");
ok((not defined $order2->{cancellationreason}), "order has no cancellation reason");
ok((not defined GetBiblio($order2->{biblionumber})), "biblio does not exist anymore");

my $order4 = GetOrder($ordernumbers[3]);
$error = DelOrder($order4->{biblionumber}, $order4->{ordernumber}, 1, "foobar");
ok((not defined $error), "DelOrder does not fail");
$order4 = GetOrder($order4->{ordernumber});
ok((defined $order4->{datecancellationprinted}), "order is cancelled");
ok(($order4->{cancellationreason} eq "foobar"), "order has cancellation reason \"foobar\"");
ok((not defined GetBiblio($order4->{biblionumber})), "biblio does not exist anymore");

my $order5 = GetOrder($ordernumbers[4]);
C4::Items::AddItem( { barcode => '0102030405' }, $order5->{biblionumber} );
$error = DelOrder($order5->{biblionumber}, $order5->{ordernumber}, 1);
$order5 = GetOrder($order5->{ordernumber});
ok((defined $order5->{datecancellationprinted}), "order is cancelled");
ok(GetBiblio($order5->{biblionumber}), "biblio still exists");

# End of tests for DelOrder

subtest 'ModOrder' => sub {
    plan tests => 1;
    ModOrder( { ordernumber => $order1->{ordernumber}, unitprice => 42 } );
    my $order = GetOrder( $order1->{ordernumber} );
    is( int($order->{unitprice}), 42, 'ModOrder should work even if biblionumber if not passed');
};

# Budget reports
my $all_count = scalar GetBudgetsReport();
ok($all_count >= 1, "GetBudgetReport OK");

my $active_count = scalar GetBudgetsReport(1);
ok($active_count >= 1 , "GetBudgetsReport(1) OK");

is($all_count, scalar GetBudgetsReport(), "GetBudgetReport returns inactive budget period acquisitions.");
ok($active_count >= scalar GetBudgetsReport(1), "GetBudgetReport doesn't return inactive budget period acquisitions.");

$schema->storage->txn_rollback();
