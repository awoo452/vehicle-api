# app/services/external_api/car_service.rb
require "net/http"
require "json"

module ExternalApi
  class CarService
    BASE_URL = "https://vpic.nhtsa.dot.gov/api/vehicles"
    DEFAULT_CATEGORY = "all"
    CATEGORY_TYPES = {
      "all" => [
        "Passenger Car",
        "Multipurpose",
        "Truck",
        "Bus",
        "Motorcycle",
        "Low Speed Vehicle"
      ],
      "passenger" => ["Passenger Car"],
      "mpv" => ["Multipurpose"],
      "truck" => ["Truck"],
      "bus" => ["Bus"],
      "two_wheel" => ["Motorcycle"],
      "low_speed" => ["Low Speed Vehicle"]
    }.freeze
    MAX_MODEL_ATTEMPTS = 6

    def self.random_vehicle(filters = {})
      category = normalize_category(filters)
      vehicle_types = category_vehicle_types(category)
      last_error = nil

      MAX_MODEL_ATTEMPTS.times do
        vehicle_type = vehicle_types.sample
        makes = fetch_makes_for_vehicle_type(vehicle_type)
        if makes.empty?
          last_error = "No makes returned for #{vehicle_type}"
          next
        end

        make = makes.sample
        make_id = make["MakeId"] || make["Make_ID"]
        make_name = make["MakeName"] || make["Make_Name"]
        raise "Make name missing from NHTSA response" if make_name.to_s.strip.empty?

        models = fetch_models(make_id, make_name, vehicle_type)
        filtered_models = filter_models(models, make_name)

        if filtered_models.any?
          model = filtered_models.sample
          return normalize_model(make, model, vehicle_type, category)
        end

        last_error = "No models returned for #{make_name} (#{vehicle_type})"
      end

      raise last_error || "No models returned for category #{category}"
    end

    def self.random_car(filters = {})
      random_vehicle(filters)
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

    def self.fetch_models(make_id, make_name, vehicle_type = nil)
      uri = build_models_uri(make_id, make_name, vehicle_type)
      raise "NHTSA request missing make identifier" if uri.nil?
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

    def self.fetch_makes_for_vehicle_type(vehicle_type)
      encoded_type = URI.encode_www_form_component(vehicle_type)
      uri = URI("#{BASE_URL}/GetMakesForVehicleType/#{encoded_type}?format=json")
      response = Net::HTTP.get_response(uri)

      unless response.is_a?(Net::HTTPSuccess)
        raise "NHTSA failed: #{response.code}"
      end

      body = JSON.parse(response.body)
      body["Results"] || []
    end

    def self.normalize_model(make, model, vehicle_type, category)
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
        category: category,
        vehicle_type: vehicle_type,
        raw: {
          make: make,
          model: model,
        },
      }
    end

    def self.filter_models(models, make_name)
      models.select do |model|
        model_name = model["Model_Name"].to_s.strip
        next false if model_name.empty?

        normalized_model = normalize_string(model_name)
        normalized_make = normalize_string(make_name.to_s)
        normalized_model != normalized_make
      end
    end

    def self.normalize_string(value)
      value.to_s.downcase.gsub(/[^a-z0-9]/, "")
    end

    def self.normalize_category(filters)
      raw =
        if filters.is_a?(Hash)
          filters[:category] || filters["category"]
        end
      key = raw.to_s.strip.downcase
      CATEGORY_TYPES.key?(key) ? key : DEFAULT_CATEGORY
    end

    def self.category_vehicle_types(category)
      CATEGORY_TYPES[category] || CATEGORY_TYPES[DEFAULT_CATEGORY]
    end

    def self.build_models_uri(make_id, make_name, vehicle_type)
      if vehicle_type.to_s.strip.empty?
        return if make_id.to_s.strip.empty?

        return URI("#{BASE_URL}/GetModelsForMakeId/#{make_id}?format=json")
      end

      encoded_type = URI.encode_www_form_component(vehicle_type)
      if make_id.to_s.strip.empty?
        encoded_name = URI.encode_www_form_component(make_name)
        URI("#{BASE_URL}/GetModelsForMakeYear/make/#{encoded_name}/vehicletype/#{encoded_type}?format=json")
      else
        URI("#{BASE_URL}/GetModelsForMakeIdYear/makeId/#{make_id}/vehicletype/#{encoded_type}?format=json")
      end
    end

    private_class_method :fetch_makes,
                          :fetch_models,
                          :random_make,
                          :fetch_makes_for_vehicle_type,
                          :normalize_model,
                          :filter_models,
                          :normalize_string,
                          :normalize_category,
                         :category_vehicle_types,
                         :build_models_uri
  end
end
