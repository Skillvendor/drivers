class StoreDriversService
  TOPIC_NAME = 'driver-location'

  def self.call
    consumer = NsqConsumerService.new(TOPIC_NAME)

    loop do
      msg = consumer.call
      if msg
        begin
          msg = JSON.parse(msg)
          StoreDataService.new(msg, generate_key(msg)).call
          consumer.finished_processing_msg
        rescue
          consumer.terminate
          self.call
        end
      else
        sleep 0.2
      end
    end
  end

  private

  def self.generate_key(msg)
    DriverCacheKeyGenerator.call(msg['id'])
  end
end