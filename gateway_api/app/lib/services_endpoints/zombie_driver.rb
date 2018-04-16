module ServicesEndpoints
  class ZombieDriver
    def self.check_zombification(id)
      begin
        RestClient.get endpoint + driver_path(id)
      rescue => e
        #if the server is not up or errors occur from our point of view there is no data about the driver
        raise JsonErrorsHandler::ZombieDriverServerError.new(e.try(:response))
      end
    end


    private
    
    def self.endpoint
      ENV['ZOMBIE_DRIVER_SERVICE_ADDRESS']
    end

    def self.driver_path(id)
      "/drivers/#{id}"
    end
  end
end