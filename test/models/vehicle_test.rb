require "test_helper"

class VehicleTest < ActiveSupport::TestCase
  test "can nullify request logs on destroy" do
    vehicle = Vehicle.create!(
      name: "BMW 318i",
      external_id: "bmw-318i",
      make: "BMW",
      model: "318i",
      year: 1995,
      fuel_type: "gas",
      body: "sedan",
      raw_data: { "make" => "BMW" }
    )

    log = RequestLog.create!(
      request_id: SecureRandom.uuid,
      http_method: "GET",
      path: "/cars/random",
      status: 200,
      duration_ms: 10,
      vehicle_id: vehicle.id
    )

    vehicle.destroy!

    assert_nil log.reload.vehicle_id
  end
end
