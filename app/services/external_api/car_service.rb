# app/services/external_api/car_service.rb
require "net/http"
require "json"

module ExternalApi
  class CarService
    BASE_URL = "https://vpic.nhtsa.dot.gov/api/vehicles"
    UPSTREAM_SERVICE = "NHTSA"
    DEFAULT_CATEGORY = "all"
    MIN_MODEL_YEAR = 1996
    CATEGORY_TYPES = {
      "all" => [
        { query: "car", label: "Passenger Car" },
        { query: "mpv", label: "MPV/SUV" },
        { query: "truck", label: "Truck" },
        { query: "bus", label: "Bus" },
        { query: "motorcycle", label: "Motorcycle" }
      ],
      "passenger" => [{ query: "car", label: "Passenger Car" }],
      "mpv" => [{ query: "mpv", label: "MPV/SUV" }],
      "truck" => [{ query: "truck", label: "Truck" }],
      "bus" => [{ query: "bus", label: "Bus" }],
      "two_wheel" => [{ query: "motorcycle", label: "Motorcycle" }]
    }.freeze
    MAX_MODEL_ATTEMPTS = 6

    def self.random_vehicle(filters = {})
      category = normalize_category(filters)
      vehicle_types = category_vehicle_types(category)
      last_error = nil

      MAX_MODEL_ATTEMPTS.times do |attempt|
        vehicle_type_entry = vehicle_types.sample
        vehicle_type_query = vehicle_type_entry[:query]
        vehicle_type_label = vehicle_type_entry[:label]
        model_year = random_model_year
        context = {
          "category" => category,
          "vehicle_type_query" => vehicle_type_query,
          "vehicle_type_label" => vehicle_type_label,
          "model_year" => model_year,
          "attempt" => attempt + 1
        }
        makes = fetch_makes_for_vehicle_type(vehicle_type_query, context: context)
        if makes.empty?
          last_error = "No makes returned for #{vehicle_type_label}"
          next
        end

        make = makes.sample
        make_id = make["MakeId"] || make["Make_ID"]
        make_name = make["MakeName"] || make["Make_Name"]
        raise "Make name missing from NHTSA response" if make_name.to_s.strip.empty?

        models = fetch_models(
          make_id,
          make_name,
          vehicle_type_query,
          model_year,
          context: context.merge(
            "make_id" => make_id,
            "make_name" => make_name
          )
        )
        filtered_models = filter_models(models, make_name)

        if filtered_models.any?
          model = filtered_models.sample
          return normalize_model(make, model, vehicle_type_label, category, model_year)
        end

        last_error = "No models returned for #{make_name} (#{vehicle_type_label})"
      end

      raise last_error || "No models returned for category #{category}"
    end

    def self.random_car(filters = {})
      random_vehicle(filters)
    end

    def self.fetch_makes(context: {})
      uri = URI("#{BASE_URL}/getallmakes?format=json")
      body = fetch_json(uri, context: context)
      body["Results"] || []
    end

    def self.fetch_models(make_id, make_name, vehicle_type = nil, model_year = nil, context: {})
      uri = build_models_uri(make_id, make_name, vehicle_type, model_year)
      raise "NHTSA request missing make identifier" if uri.nil?
      body = fetch_json(uri, context: context)
      body["Results"] || []
    end

    def self.random_make
      makes = fetch_makes
      raise "No makes returned" if makes.empty?

      makes.sample
    end

    def self.fetch_makes_for_vehicle_type(vehicle_type, context: {})
      encoded_type = URI.encode_www_form_component(vehicle_type)
      uri = URI("#{BASE_URL}/GetMakesForVehicleType/#{encoded_type}?format=json")
      body = fetch_json(uri, context: context.merge("vehicle_type" => vehicle_type))
      body["Results"] || []
    end

    def self.normalize_model(make, model, vehicle_type, category, model_year)
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
        model_year: model_year,
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

    def self.random_model_year
      current_year = Time.now.year
      min_year = [MIN_MODEL_YEAR, current_year].min
      rand(min_year..current_year)
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

    def self.build_models_uri(make_id, make_name, vehicle_type, model_year)
      year = model_year || random_model_year
      if vehicle_type.to_s.strip.empty?
        return if make_id.to_s.strip.empty?

        return URI("#{BASE_URL}/GetModelsForMakeIdYear/makeId/#{make_id}/modelyear/#{year}?format=json")
      end

      encoded_type = URI.encode_www_form_component(vehicle_type)
      if make_id.to_s.strip.empty?
        encoded_name = URI.encode_www_form_component(make_name)
        URI("#{BASE_URL}/GetModelsForMakeYear/make/#{encoded_name}/modelyear/#{year}/vehicletype/#{encoded_type}?format=json")
      else
        URI("#{BASE_URL}/GetModelsForMakeIdYear/makeId/#{make_id}/modelyear/#{year}/vehicletype/#{encoded_type}?format=json")
      end
    end

    def self.fetch_json(uri, context:)
      response = Net::HTTP.get_response(uri)
      unless response.is_a?(Net::HTTPSuccess)
        raise_upstream_error(
          "NHTSA failed: #{response.code} #{response.message}",
          response,
          uri,
          context
        )
      end

      JSON.parse(response.body)
    rescue ExternalApi::UpstreamError
      raise
    rescue JSON::ParserError => e
      raise_upstream_error(
        "NHTSA returned invalid JSON",
        response,
        uri,
        context.merge("parse_error" => e.message)
      )
    rescue StandardError => e
      raise ExternalApi::UpstreamError.new(
        message: "NHTSA request failed: #{e.class}",
        service: UPSTREAM_SERVICE,
        status: nil,
        method: "GET",
        url: uri.to_s,
        response_body: nil,
        context: normalize_context(context).merge(
          "network_error" => {
            "class" => e.class.name,
            "message" => e.message
          }
        )
      )
    end

    def self.raise_upstream_error(message, response, uri, context)
      raise ExternalApi::UpstreamError.new(
        message: message,
        service: UPSTREAM_SERVICE,
        status: response&.code&.to_i,
        method: "GET",
        url: uri.to_s,
        response_body: response_body_excerpt(response&.body),
        context: normalize_context(context).merge(
          "response_message" => response&.message,
          "response_code" => response&.code
        )
      )
    end

    def self.response_body_excerpt(body)
      text = body.to_s
      return if text.strip.empty?

      excerpt = text[0, 500]
      excerpt.encode("UTF-8", invalid: :replace, undef: :replace, replace: "?")
    end

    def self.normalize_context(context)
      context.each_with_object({}) do |(key, value), normalized|
        normalized[key.to_s] = value
      end
    end

    private_class_method :fetch_makes,
                          :fetch_models,
                          :random_make,
                          :fetch_makes_for_vehicle_type,
                          :normalize_model,
                          :filter_models,
                          :normalize_string,
                          :random_model_year,
                          :normalize_category,
                          :category_vehicle_types,
                          :build_models_uri,
                          :fetch_json,
                          :raise_upstream_error,
                          :response_body_excerpt,
                          :normalize_context
  end
end
