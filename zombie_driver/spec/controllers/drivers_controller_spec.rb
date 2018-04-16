require 'rails_helper'

describe 'DriversController', type: :request do
  describe 'GET /drivers/:id' do
    let(:driver_id) { 5 }
    let(:minutes)  { ZombieRequestService::DEFAULT_MINUTES_PERIOD }

    context 'driver location service is running' do
      let(:data) do
        [ 
          {"id"=>"5", "latitude"=>"82", "longitude"=>"30" },
          {"id"=>"5", "latitude"=>"79", "longitude"=>"32" },
          {"id"=>"5", "latitude"=>"82", "longitude"=>"37" }
        ]
      end
      let(:response_hash) do
        {
          'id' => "#{driver_id}",
          'zombie' => false
        }
      end
      
      def stub_zombie_driver_request
        stub_request(:get, "#{ENV['DRIVER_LOCATION_SERVICE_ADDRESS']}/drivers/#{driver_id}/coordinates?minutes=#{minutes}")
          .to_return(body: data.to_json , headers: {}, status: 200)
      end

      before { stub_zombie_driver_request }

      it 'responds with the right data' do
        api_get "/drivers/#{driver_id}"

        result = JSON.parse(response.body)
        expect(result).to eq(response_hash)
      end
    end

    context 'driver location service is down' do
      def stub_driver_location_request
        stub_request(:get, "#{ENV['DRIVER_LOCATION_SERVICE_ADDRESS']}/drivers/#{driver_id}/coordinates?minutes=#{minutes}")
          .and_raise(Errno::ECONNREFUSED.new)
      end
  
      before { stub_driver_location_request }

      it 'responds with error' do
        api_get "/drivers/#{driver_id}"

        result = JSON.parse(response.body)
        expect(result).to eq({"errors"=>[{"title"=>"Driver Location Server doesn't answer"}]})
      end
    end

    context 'driver location service has encountered an error' do
      def stub_driver_location_request
        stub_request(:get, "#{ENV['DRIVER_LOCATION_SERVICE_ADDRESS']}/drivers/#{driver_id}/coordinates?minutes=#{minutes}")
          .to_return(body: { error: 'Internal Server Error' }.to_json, headers: {}, status: 500)
      end
  
      before { stub_driver_location_request }

      it 'responds with error' do
        api_get "/drivers/#{driver_id}"

        result = JSON.parse(response.body)
        expect(result).to eq({"errors"=>[{"title"=>"Driver Location Server doesn't answer"}]})
      end
    end
  end
end