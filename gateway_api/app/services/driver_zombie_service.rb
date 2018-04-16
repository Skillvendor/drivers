class DriverZombieService
  def self.get_info(driver_id)
    response = ServicesEndpoints::ZombieDriver.check_zombification(driver_id).body
    response ||= "{}"

    JSON.parse(response)
  end
end