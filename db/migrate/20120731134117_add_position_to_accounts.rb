class AddPositionToAccounts < ActiveRecord::Migration[4.2]
  def change
    add_column :accounts, :position, :integer
  end
end
