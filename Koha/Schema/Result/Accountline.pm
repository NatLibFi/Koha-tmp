use utf8;
package Koha::Schema::Result::Accountline;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::Accountline

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<accountlines>

=cut

__PACKAGE__->table("accountlines");

=head1 ACCESSORS

=head2 accountlines_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 issue_id

  data_type: 'integer'
  is_nullable: 1

=head2 borrowernumber

  data_type: 'integer'
  default_value: 0
  is_foreign_key: 1
  is_nullable: 0

=head2 accountno

  data_type: 'smallint'
  default_value: 0
  is_nullable: 0

=head2 itemnumber

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 date

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 amount

  data_type: 'decimal'
  is_nullable: 1
  size: [28,6]

=head2 description

  data_type: 'mediumtext'
  is_nullable: 1

=head2 dispute

  data_type: 'mediumtext'
  is_nullable: 1

=head2 accounttype

  data_type: 'varchar'
  is_nullable: 1
  size: 5

=head2 amountoutstanding

  data_type: 'decimal'
  is_nullable: 1
  size: [28,6]

=head2 lastincrement

  data_type: 'decimal'
  is_nullable: 1
  size: [28,6]

=head2 timestamp

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=head2 notify_id

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 notify_level

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 note

  data_type: 'text'
  is_nullable: 1

=head2 manager_id

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "accountlines_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "issue_id",
  { data_type => "integer", is_nullable => 1 },
  "borrowernumber",
  {
    data_type      => "integer",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "accountno",
  { data_type => "smallint", default_value => 0, is_nullable => 0 },
  "itemnumber",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "date",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "amount",
  { data_type => "decimal", is_nullable => 1, size => [28, 6] },
  "description",
  { data_type => "mediumtext", is_nullable => 1 },
  "dispute",
  { data_type => "mediumtext", is_nullable => 1 },
  "accounttype",
  { data_type => "varchar", is_nullable => 1, size => 5 },
  "amountoutstanding",
  { data_type => "decimal", is_nullable => 1, size => [28, 6] },
  "lastincrement",
  { data_type => "decimal", is_nullable => 1, size => [28, 6] },
  "timestamp",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "notify_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "notify_level",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "note",
  { data_type => "text", is_nullable => 1 },
  "manager_id",
  { data_type => "integer", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</accountlines_id>

=back

=cut

__PACKAGE__->set_primary_key("accountlines_id");

=head1 RELATIONS

=head2 borrowernumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Borrower>

=cut

__PACKAGE__->belongs_to(
  "borrowernumber",
  "Koha::Schema::Result::Borrower",
  { borrowernumber => "borrowernumber" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 itemnumber

Type: belongs_to

Related object: L<Koha::Schema::Result::Item>

=cut

__PACKAGE__->belongs_to(
  "itemnumber",
  "Koha::Schema::Result::Item",
  { itemnumber => "itemnumber" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "SET NULL",
  },
);

=head2 payments_transactions

Type: has_many

Related object: L<Koha::Schema::Result::PaymentsTransaction>

=cut

__PACKAGE__->has_many(
  "payments_transactions",
  "Koha::Schema::Result::PaymentsTransaction",
  { "foreign.accountlines_id" => "self.accountlines_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 payments_transactions_accountlines

Type: has_many

Related object: L<Koha::Schema::Result::PaymentsTransactionsAccountline>

=cut

__PACKAGE__->has_many(
  "payments_transactions_accountlines",
  "Koha::Schema::Result::PaymentsTransactionsAccountline",
  { "foreign.accountlines_id" => "self.accountlines_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 vetuma_transaction_accountlines_links

Type: has_many

Related object: L<Koha::Schema::Result::VetumaTransactionAccountlinesLink>

=cut

__PACKAGE__->has_many(
  "vetuma_transaction_accountlines_links",
  "Koha::Schema::Result::VetumaTransactionAccountlinesLink",
  { "foreign.accountlines_id" => "self.accountlines_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 transactions

Type: many_to_many

Composing rels: L</vetuma_transaction_accountlines_links> -> transaction

=cut

__PACKAGE__->many_to_many(
  "transactions",
  "vetuma_transaction_accountlines_links",
  "transaction",
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2016-01-26 17:18:34
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:RCQohhphtg+0+RszpB4wLg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
