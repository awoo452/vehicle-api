# app/controllers/api/cars_controller.rb
module Api
  class CarsController < ApplicationController
    def random
      filters = {
        fuel_type: params[:fuel_type],
        make: params[:make],
        body: params[:body],
        year: params[:year]
      }

      result = ExternalApi::CarService.random_car(filters)
      normalized = result["normalized"] || {}
      raw = result["raw"]
      metadata = result["metadata"] || {}

      if metadata["error"] == "no_results"
        append_request_log_metadata(
          vehicle: {
            "error" => metadata["error"],
            "filters" => metadata["filters"]
          },
          persist_param: params[:persist],
          vehicle_id: nil
        )

        return render json: { error: "No vehicles found for that query." }, status: :not_found
      end

      vehicle_record = nil
      persist = params.fetch(:persist, "true").to_s.downcase != "false"
      if persist && normalized["external_id"].present?
        vehicle_record = Vehicle.find_or_initialize_by(external_id: normalized["external_id"])
        vehicle_record.assign_attributes(
          name: normalized["name"],
          make: normalized["make"],
          model: normalized["model"],
          year: normalized["year"],
          fuel_type: normalized["fuel_type"],
          body: normalized["body"],
          image_url: normalized["image_url"],
          raw_data: raw
        )
        vehicle_record.save
        set_request_log_vehicle_id(vehicle_record.id) if vehicle_record.persisted?
      end

      append_request_log_metadata(
        vehicle: {
          "external_id" => normalized["external_id"],
          "name" => normalized["name"],
          "make" => normalized["make"],
          "model" => normalized["model"],
          "year" => normalized["year"],
          "fuel_type" => normalized["fuel_type"],
          "body" => normalized["body"],
          "upstream_status" => metadata["upstream_status"],
          "filters" => metadata["filters"]
        },
        persist_param: params[:persist],
        vehicle_id: vehicle_record&.id
      )

      render json: {
        name: normalized["name"],
        external_id: normalized["external_id"],
        make: normalized["make"],
        model: normalized["model"],
        year: normalized["year"],
        fuel_type: normalized["fuel_type"],
        body: normalized["body"],
        raw: raw
      }
    end
  end
end
