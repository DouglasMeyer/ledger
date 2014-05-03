class CreateBankImport < ActiveRecord::Migration
  def change
    create_table :bank_imports do |t|
      t.integer :balance_cents, null: false
      t.timestamps null: false
    end
  end
end
