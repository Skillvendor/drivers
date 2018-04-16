class DriversController < ApplicationController
  def coordinates
    minutes_ago = params[:minutes].to_i if params[:minutes]
    @coordinates = CoordinatesExtractionService.new(DriverFetcher.new(params[:id]), minutes_ago).call
    raise ActiveRecord::RecordNotFound unless @coordinates.present?

    json_response(@coordinates)
  end
end