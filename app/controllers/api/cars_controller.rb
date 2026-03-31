# app/controllers/api/cars_controller.rb
module Api
  class CarsController < ApplicationController
    def random
      vehicle = ExternalApi::CarService.random_vehicle(category: params[:category])

      render json: vehicle
    rescue ExternalApi::UpstreamError => e
      append_request_log_metadata("upstream" => e.metadata)
      Rails.logger.error("[CarsController] Upstream failure #{e.log_message}")

      render json: {
        error: "Upstream failure",
        upstream: e.metadata,
        request_id: request.request_id
      }, status: :bad_gateway
    rescue => e
      Rails.logger.error("[CarsController] #{e.message}")

      render json: { error: "Upstream failure" }, status: :bad_gateway
    end
  end
end
