class AddUniquenessIndex < ActiveRecord::Migration[5.0]
  def change
    def change
      add_index :houses, :external_id, unique: true
    end
  end
end
