class CreateLedgers < ActiveRecord::Migration
  def change
    create_table :ledgers do |t|
      t.string :name, :null => false
      t.string :bank

      t.timestamps
    end
  end
end
