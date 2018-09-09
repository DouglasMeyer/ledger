class Strategy < ActiveRecord::Migration[4.2]
  def up
    create_table :strategies do |t|
      t.string  :strategy_type, null: false, default: 'fixed'
      t.decimal :variable, precision: 9, scale: 2
    end

    change_table :accounts do |t|
      t.references :strategy
    end

    change_table :account_entries do |t|
      t.references :strategy
    end
  end

  def down
    change_table :account_entries do |t|
      t.remove :strategy_id
    end

    change_table :accounts do |t|
      t.remove :strategy_id
    end

    drop_table :strategies
  end
end
