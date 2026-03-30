class RequestLog < ApplicationRecord
  self.table_name = "vehicle_api_request_logs"

  belongs_to :vehicle, optional: true
end
