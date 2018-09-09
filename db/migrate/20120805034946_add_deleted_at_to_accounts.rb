class AddDeletedAtToAccounts < ActiveRecord::Migration[4.2]
  def change
    add_column :accounts, :deleted_at, :datetime
  end
end
