class CoordinatesExtractionService
  MINUTES_AGO = 5

  def initialize(driver_fetcher, start_time)
    @driver_fetcher = driver_fetcher
    start_time ||= MINUTES_AGO
    @start_time = start_time.minutes.ago
  end

  def call
    data = @driver_fetcher.call
    data = data.select { |driver| DateTime.parse(driver["updated_at"]) >= @start_time} if data.present?
    data
  end
end