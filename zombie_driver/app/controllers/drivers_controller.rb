class DriversController < ApplicationController
  def show
    response = ZombieRequestService.call(params[:id])

    json_response(response)
  end
end