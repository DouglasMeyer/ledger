class BankEntryDescriptionCanBeNull < ActiveRecord::Migration[4.2]
  def change
    change_column_null :bank_entries, :description, true
  end
end
