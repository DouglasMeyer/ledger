class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.integer :ledger_id
      t.string :name

      t.timestamps
    end

    change_table :entries do |t|
      t.remove :account
      t.references :account
    end
  end
end
