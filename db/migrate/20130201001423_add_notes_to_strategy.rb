class AddNotesToStrategy < ActiveRecord::Migration
  def change
    add_column :strategies, :notes, :text
  end
end
