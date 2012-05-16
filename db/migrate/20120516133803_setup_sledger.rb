class SetupSledger < ActiveRecord::Migration
  def change
    create_table :bank_entries do |t|
      t.date    :date,        :null => false
      t.decimal :ammount,     :null => false, :precision => 9, :scale => 2 # 1_234_567_89
      t.text    :notes

      t.string  :description, :null => false
      t.string  :external_id

      t.timestamps
    end
    add_index :bank_entries, :external_id, :unique => true


    create_table :accounts do |t|
      t.string :name, :null => false

      t.timestamps
    end
    add_index :accounts, :name, :unique => true


    create_table :account_entries do |t|
      t.references  :account,     :null => false
      t.references  :bank_entry,  :null => false
      t.decimal     :ammount,     :null => false, :precision => 9, :scale => 2 # 1_234_567_89
      t.text        :notes

      t.timestamps
    end
  end
end
