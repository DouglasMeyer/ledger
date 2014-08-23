class BankEntryDescriptionCanBeNull < ActiveRecord::Migration
  def change
    change_column_null :bank_entries, :description, true
  end
end
