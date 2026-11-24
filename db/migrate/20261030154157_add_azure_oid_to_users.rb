class AddAzureOidToUsers < ActiveRecord::Migration[8.1]
  # The Entra immutable object id, and the identifier PQ pins an account to.
  #
  # Nullable: every row predating OAuth has no oid until its owner first signs
  # in, and the unique index below tolerates many NULLs in Postgres. Do not add
  # `null: false` later without a backfill — it would lock out everyone who has
  # not yet signed in.
  #
  # Unique: this is what makes the trust-on-first-use email link unclaimable
  # twice, including when two concurrent callbacks race for the same unlinked
  # account.
  def change
    add_column :users, :azure_oid, :string
    add_index :users, :azure_oid, unique: true
  end
end
