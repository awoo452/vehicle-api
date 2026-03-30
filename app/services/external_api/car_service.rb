# app/services/external_api/car_service.rb
require "net/http"
require "json"

module ExternalApi
  class CarService
    BASE_URL = "https://vpic.nhtsa.dot.gov/api/vehicles"

    def self.random_vehicle
      make = random_make
      make_name = make["Make_Name"]
      raise "Make name missing from NHTSA response" if make_name.to_s.strip.empty?

      models = fetch_models(make_name)
      raise "No models returned for #{make_name}" if models.empty?

      model = models.sample
      normalize_model(make, model)
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

    def self.fetch_models(make_name)
      encoded_name = URI.encode_www_form_component(make_name)
      uri = URI("#{BASE_URL}/getmodelsformake/#{encoded_name}?format=json")
      response = Net::HTTP.get_response(uri)

      unless response.is_a?(Net::HTTPSuccess)
        raise "NHTSA failed: #{response.code}"
      end

      body = JSON.parse(response.body)
      body["Results"] || []
    end

    def self.random_make
      makes = fetch_makes
      raise "No makes returned" if makes.empty?

      makes.sample
    end

    def self.normalize_model(make, model)
      make_id = model["Make_ID"] || make["Make_ID"]
      make_name = model["Make_Name"] || make["Make_Name"]
      model_id = model["Model_ID"]
      model_name = model["Model_Name"]

      {
        make_id: make_id,
        make_name: make_name,
        model_id: model_id,
        model_name: model_name,
        name: [make_name, model_name].compact.join(" "),
        raw: {
          make: make,
          model: model,
        },
      }
    end
    private_class_method :fetch_makes, :fetch_models, :random_make, :normalize_model
  end
end
