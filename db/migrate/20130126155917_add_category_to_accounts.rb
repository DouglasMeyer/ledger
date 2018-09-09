class AddCategoryToAccounts < ActiveRecord::Migration[4.2]
  def change
    add_column :accounts, :category, :string
  end
end
