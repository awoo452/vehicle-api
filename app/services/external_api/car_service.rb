# app/services/external_api/car_service.rb
require "net/http"
require "json"

module ExternalApi
  class CarService
    BASE_URL = "https://vpic.nhtsa.dot.gov/api/vehicles"

    def self.random_vehicle
      makes = fetch_makes
      raise "No makes returned" if makes.empty?

      makes.sample
    end

    def self.random_car(_filters = {})
      random_vehicle
    end

    def self.fetch_makes
      uri = URI("#{BASE_URL}/getallmakes?format=json")
      response = Net::HTTP.get_response(uri)

      unless response.is_a?(Net::HTTPSuccess)
        raise "NHTSA failed: #{response.code}"
      end

      body = JSON.parse(response.body)
      body["Results"] || []
    end
    private_class_method :fetch_makes
  end
end
