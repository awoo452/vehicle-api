class RenameCarTablesToVehicleTables < ActiveRecord::Migration[8.1]
  def change
    if table_exists?(:vehicle_api_cars) && !table_exists?(:vehicle_api_vehicles)
      rename_table :vehicle_api_cars, :vehicle_api_vehicles
    end

    if table_exists?(:vehicle_api_request_logs)
      if column_exists?(:vehicle_api_request_logs, :car_id) && !column_exists?(:vehicle_api_request_logs, :vehicle_id)
        rename_column :vehicle_api_request_logs, :car_id, :vehicle_id
      end
    end

    rename_vehicle_indexes
    rename_request_log_indexes
    update_request_log_foreign_key
  end

  private

  def rename_vehicle_indexes
    rename_index_if_present(:vehicle_api_vehicles,
      "index_vehicle_api_cars_on_external_id",
      "index_vehicle_api_vehicles_on_external_id")
  end

  def rename_request_log_indexes
    rename_index_if_present(:vehicle_api_request_logs,
      "index_vehicle_api_request_logs_on_car_id",
      "index_vehicle_api_request_logs_on_vehicle_id")
    rename_index_if_present(:vehicle_api_request_logs,
      "index_vehicle_api_request_logs_on_car_id_and_created_at",
      "index_vehicle_api_request_logs_on_vehicle_id_and_created_at")
  end

  def rename_index_if_present(table, old_name, new_name)
    return unless index_name_exists?(table, old_name)

    rename_index table, old_name, new_name
  end

  def update_request_log_foreign_key
    return unless table_exists?(:vehicle_api_request_logs)

    if foreign_key_exists?(:vehicle_api_request_logs, :vehicle_api_cars, column: :car_id)
      remove_foreign_key :vehicle_api_request_logs, column: :car_id
    end

    return unless table_exists?(:vehicle_api_vehicles)

    unless foreign_key_exists?(:vehicle_api_request_logs, :vehicle_api_vehicles, column: :vehicle_id)
      add_foreign_key :vehicle_api_request_logs, :vehicle_api_vehicles, column: :vehicle_id
    end
  end
end
