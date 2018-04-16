class ZombieCalculatorService
  REQUIRED_METERS = 500

  def self.call(data)
    meters_moved = 0

    if data && data.size >= 2
      data.each_cons(2) do |driver_location1, driver_location2|
        current_location = extract_coordinates(driver_location1)
        moved_to = extract_coordinates(driver_location2)
        meters_moved += Geocoder::Calculations.distance_between(current_location, moved_to) * 1000
      end
    end

    REQUIRED_METERS > meters_moved
  end

  private

  def self.extract_coordinates(object)
    [ object['latitude'].to_f, object['longitude'].to_f ]
  end
end