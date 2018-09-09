class CreateProjectedEntries < ActiveRecord::Migration[4.2]
  def change
    create_table :projected_entries do |t|
      t.references :account, null: false
      t.string :description
      t.integer :amount_cents, null: false
      t.string :rrule
      t.date :date
      t.date :until_date
    end
  end
end
