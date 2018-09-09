class CreateUsers < ActiveRecord::Migration[4.2]
  def change
    create_table :users do |t|
      t.string :provider, null: false
      t.string :email, null: false
      t.string :name
    end
  end
end
