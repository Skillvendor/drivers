class ZombieRequestService
  DEFAULT_MINUTES_PERIOD = 5

  def self.call(driver_id, minutes_ago = DEFAULT_MINUTES_PERIOD)
    response = ServicesEndpoints::DriverLocation.get_position(driver_id, minutes_ago).try(:body)
    return {} unless response.present?

    data = JSON.parse(response)
    { id: driver_id, zombie: ZombieCalculatorService.call(data) }
  end
end