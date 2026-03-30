# app/services/external_api/car_service.rb
require "json"

module ExternalApi
  class CarService
    include HTTParty
    base_uri "https://www.carqueryapi.com/api/0.3"
    default_timeout 5

    def self.random_car(filters = {})
      metadata_filters = build_metadata_filters(filters)
      response = get("/", query: build_query(filters))
      payload = parse_payload(response&.body)
      trims = payload["Trims"]

      return fallback_empty(response&.code, metadata_filters) unless trims.is_a?(Array) && trims.any?

      selected = trims.sample
      normalized = normalize_trim(selected)

      {
        "raw" => selected,
        "normalized" => normalized,
        "metadata" => {
          "upstream_status" => response&.code,
          "filters" => metadata_filters
        }
      }
    end

    def self.build_query(filters)
      query = { cmd: "getTrims" }
      fuel_type = normalize_filter(filters, :fuel_type)
      make = normalize_filter(filters, :make)
      body = normalize_filter(filters, :body)
      year = normalize_year(normalize_filter(filters, :year))

      query[:fuel_type] = fuel_type if fuel_type
      query[:make] = make if make
      query[:body] = body if body

      if year
        query[:min_year] = year
        query[:max_year] = year
      end

      query
    end
    private_class_method :build_query

    def self.parse_payload(body)
      return {} if body.to_s.strip.empty?

      json = extract_json(body)
      return {} if json.empty?

      JSON.parse(json)
    rescue JSON::ParserError
      {}
    end
    private_class_method :parse_payload

    def self.extract_json(body)
      trimmed = body.to_s.strip
      start_index = trimmed.index("{")
      end_index = trimmed.rindex("}")
      return "" unless start_index && end_index && end_index > start_index

      trimmed[start_index..end_index]
    end
    private_class_method :extract_json

    def self.normalize_trim(trim)
      return {} unless trim.is_a?(Hash)

      make = trim["model_make_id"] || trim["make"]
      model = trim["model_name"] || trim["model"]
      year = normalize_year(trim["model_year"] || trim["year"])
      fuel_type = trim["model_engine_fuel"] || trim["model_engine_fuel_type"] || trim["fuel_type"]
      body = trim["model_body"] || trim["body"]
      image_url = trim["model_picture"] || trim["model_image"] || trim["image_url"]

      name = [make, model].compact.join(" ").strip
      external_id = trim["model_id"].presence || fallback_external_id(make, model, year)

      {
        "name" => name.presence,
        "external_id" => external_id,
        "make" => make,
        "model" => model,
        "year" => year,
        "fuel_type" => fuel_type,
        "body" => body,
        "image_url" => image_url
      }
    end
    private_class_method :normalize_trim

    def self.normalize_year(value)
      return nil if value.nil?

      cleaned = value.to_s.strip
      return nil unless cleaned.match?(/\A\d{4}\z/)

      cleaned.to_i
    end
    private_class_method :normalize_year

    def self.fallback_external_id(make, model, year)
      pieces = [make, model, year].compact.map { |value| value.to_s.strip.downcase }
      return nil if pieces.empty?

      pieces.join("-")
    end
    private_class_method :fallback_external_id

    def self.normalize_filter(filters, key)
      value = filters[key] || filters[key.to_s]
      value = value.to_s.strip
      value.presence
    end
    private_class_method :normalize_filter

    def self.build_metadata_filters(filters)
      {
        "fuel_type" => normalize_filter(filters, :fuel_type),
        "make" => normalize_filter(filters, :make),
        "body" => normalize_filter(filters, :body),
        "year" => normalize_year(normalize_filter(filters, :year))
      }.compact
    end
    private_class_method :build_metadata_filters

    def self.fallback_empty(status, metadata_filters)
      {
        "raw" => {},
        "normalized" => {},
        "metadata" => {
          "error" => "no_results",
          "upstream_status" => status,
          "filters" => metadata_filters
        }
      }
    end
    private_class_method :fallback_empty
  end
end
