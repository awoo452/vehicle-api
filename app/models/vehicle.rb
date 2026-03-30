class Vehicle < ApplicationRecord
  self.table_name = "vehicle_api_vehicles"

  has_many :request_logs, dependent: :nullify
end
