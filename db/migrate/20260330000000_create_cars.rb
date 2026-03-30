class CreateCars < ActiveRecord::Migration[8.1]
  def change
    create_table :vehicle_api_vehicles do |t|
      t.string :name
      t.string :external_id
      t.string :make
      t.string :model
      t.integer :year
      t.string :fuel_type
      t.string :body
      t.string :image_url
      t.jsonb :raw_data

      t.timestamps
    end

    add_index :vehicle_api_vehicles, :external_id, unique: true
  end
end
