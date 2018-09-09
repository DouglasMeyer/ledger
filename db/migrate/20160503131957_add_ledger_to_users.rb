class AddLedgerToUsers < ActiveRecord::Migration[4.2]
  class User < ActiveRecord::Base ; end

  def up
    add_column :users, :ledger, :string
    User.update_all(ledger: ENV['LEDGER_NAME'])
    change_column :users, :ledger, :string, null: false
  end

  def down
    remove_column :users, :ledger
  end
end
