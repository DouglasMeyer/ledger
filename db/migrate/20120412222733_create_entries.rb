class CreateEntries < ActiveRecord::Migration
  def change
    create_table :entries do |t|
      t.references :ledger, :null => false
      t.date :date
      t.decimal :ammount, :precision => 9, :scale => 2 # 1_234_567_89
      t.text :notes

      t.references :bank_entry
      t.string :description
      t.integer :external_id

      t.string :account

      t.timestamps
    end
    add_index :entries, :external_id, :unique => true
  end
end
