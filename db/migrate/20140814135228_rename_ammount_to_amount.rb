class RenameAmmountToAmount < ActiveRecord::Migration[4.2]
  def change
    rename_column :account_entries, :ammount_cents, :amount_cents
    rename_column :bank_entries, :ammount_cents, :amount_cents
  end
end
