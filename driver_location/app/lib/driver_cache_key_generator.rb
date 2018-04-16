class DriverCacheKeyGenerator
  def self.call(driver_id)
    "driver_#{driver_id}"
  end
end