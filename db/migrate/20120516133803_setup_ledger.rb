class SetupLedger < ActiveRecord::Migration
  def change
    create_table :bank_entries do |t|
      t.date    :date,          :null => false
      t.integer :amount_cents, :null => false
      t.text    :notes

      t.string  :description,   :null => false
      t.string  :external_id

      t.timestamps
    end
    add_index :bank_entries, :external_id, :unique => true


    create_table :accounts do |t|
      t.string :name, :null => false
      t.boolean :asset, :null => false, :default => true

      t.timestamps
    end
    add_index :accounts, :name, :unique => true


    create_table :account_entries do |t|
      t.references  :account,       :null => false
      t.references  :bank_entry,    :null => false
      t.integer     :amount_cents, :null => false
      t.text        :notes

      t.timestamps
    end
  end
end
