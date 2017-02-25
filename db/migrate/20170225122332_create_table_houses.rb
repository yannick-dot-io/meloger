class CreateTableHouses < ActiveRecord::Migration[5.0]
  def change
    create_table :houses, id: :uuid do |t|
      t.string   :external_id
      t.string   :permalink
      t.string   :title
      t.string   :description
      t.integer  :postal_code
      t.integer  :price
      t.jsonb    :payload, default: {}
      t.datetime :imported_at, default: -> { "now()" }, null: false

      t.timestamps
    end
  end
end
