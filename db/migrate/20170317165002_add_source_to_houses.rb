class AddSourceToHouses < ActiveRecord::Migration[5.0]
  def change
    add_column :houses, :source, :string
  end
end
