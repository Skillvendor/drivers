class DriverFetcher
  attr_accessor :driver_id

  def initialize(driver_id)
    @driver_id = driver_id
  end

  def call
    Rails.cache.read(::DriverCacheKeyGenerator.call(@driver_id))
  end
end