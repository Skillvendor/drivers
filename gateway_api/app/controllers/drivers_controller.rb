class DriversController < ApplicationController
  def update
    DriverLocationService.create_nsq_message(driver_params.to_h)

    render nothing: true, status: :ok
  end

  def show
    data = DriverZombieService.get_info(params[:id])

    json_response(data)
  end

  private

  def driver_params
    params.permit(:id, :latitude, :longitude)
  end
end