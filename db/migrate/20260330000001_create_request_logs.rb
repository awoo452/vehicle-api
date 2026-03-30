class CreateRequestLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :vehicle_api_request_logs do |t|
      t.string :request_id
      t.string :http_method, null: false
      t.string :path, null: false
      t.string :ip
      t.string :user_agent
      t.string :referer
      t.string :origin
      t.jsonb :params
      t.integer :status
      t.integer :duration_ms
      t.jsonb :metadata
      t.bigint :vehicle_id

      t.timestamps
    end

    add_index :vehicle_api_request_logs, :created_at
    add_index :vehicle_api_request_logs, :request_id
    add_index :vehicle_api_request_logs, :ip
    add_index :vehicle_api_request_logs, :path
    add_index :vehicle_api_request_logs, :vehicle_id
    add_index :vehicle_api_request_logs, [ :vehicle_id, :created_at ]
    add_foreign_key :vehicle_api_request_logs, :vehicle_api_vehicles, column: :vehicle_id
  end
end
