class Car < ApplicationRecord
  self.table_name = "vehicle_api_cars"

  has_many :request_logs, dependent: :nullify
end
