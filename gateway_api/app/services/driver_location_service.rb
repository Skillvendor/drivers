class DriverLocationService
  DRIVER_LOCATION_PARAMS = [:latitude, :longitude, :id]
  TOPIC_NAME = 'driver-location'

  def self.create_nsq_message(params)
    message = params.select {|v| DRIVER_LOCATION_PARAMS.include?(v.to_sym)}.merge!({updated_at: DateTime.current}).to_json
    producer = NsqService.new(TOPIC_NAME)
    producer.publish(message)
  end
end