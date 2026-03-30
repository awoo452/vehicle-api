# app/controllers/api/cars_controller.rb
module Api
  class CarsController < ApplicationController
    def random
      vehicle = ExternalApi::CarService.random_vehicle(category: params[:category])

      render json: vehicle
    rescue => e
      Rails.logger.error("[CarsController] #{e.message}")

      render json: { error: "Upstream failure" }, status: :bad_gateway
    end
  end
end
