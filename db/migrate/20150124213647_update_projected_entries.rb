class UpdateProjectedEntries < ActiveRecord::Migration
  def change
    change_table :projected_entries do |t|
      t.remove :date, :until_date
      t.change :rrule, :string, null: false
    end
  end
end
