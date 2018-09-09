class CreateBankImport < ActiveRecord::Migration[4.2]
  def change
    create_table :bank_imports do |t|
      t.integer :balance_cents, null: false
      t.timestamps null: false
    end
  end
end
