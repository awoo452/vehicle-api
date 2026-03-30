require "test_helper"

class CarsControllerTest < ActionDispatch::IntegrationTest
  def with_car_service_stub(return_value: nil, raise_error: nil)
    original = ExternalApi::CarService.method(:random_vehicle)
    ExternalApi::CarService.define_singleton_method(:random_vehicle) do |**_kwargs|
      raise raise_error if raise_error

      return_value
    end

    yield
  ensure
    ExternalApi::CarService.define_singleton_method(:random_vehicle, original)
  end

  test "random returns payload without persisting" do
    payload = {
      "make_id" => 440,
      "make_name" => "BMW",
      "model_id" => 1234,
      "model_name" => "318i",
      "name" => "BMW 318i",
      "category" => "passenger",
      "vehicle_type" => "Passenger Car",
      "model_year" => 2021
    }

    with_car_service_stub(return_value: payload) do
      assert_difference("RequestLog.count", 1) do
        get "/cars/random", params: { persist: "false", category: "passenger" }
      end
    end

    assert_response :success
    assert_equal payload, JSON.parse(response.body)
  end

  test "random returns 502 when the service fails" do
    with_car_service_stub(raise_error: StandardError.new("boom")) do
      assert_difference("RequestLog.count", 1) do
        get "/cars/random", params: { persist: "false" }
      end
    end

    assert_response :bad_gateway
    assert_equal "Upstream failure", JSON.parse(response.body)["error"]
  end
end
