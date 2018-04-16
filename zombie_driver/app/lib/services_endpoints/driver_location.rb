module ServicesEndpoints
  class DriverLocation
    def self.get_position(id, minutes_ago=5)
      begin
        RestClient.get endpoint + driver_path(id, minutes_ago)
      rescue => e
        #if the server is not up or errors occur from our point of view there is no data about the driver
        raise JsonErrorsHandler::DriverLocationServerError.new(e.try(:response))
      end
    end


    private
    
    def self.endpoint
      ENV['DRIVER_LOCATION_SERVICE_ADDRESS']
    end

    def self.driver_path(id, minutes_ago)
      "/drivers/#{id}/coordinates?minutes=#{minutes_ago}"
    end
  end
end