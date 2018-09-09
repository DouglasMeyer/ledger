class AddNotesToStrategy < ActiveRecord::Migration[4.2]
  def change
    add_column :strategies, :notes, :text
  end
end
