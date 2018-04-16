require 'rails_helper'

describe ZombieRequestService do
  subject { ZombieRequestService }

  let(:driver_id) { 5 }
  let(:minutes_ago) { 5 }

  describe '#check_zombification' do
    context 'driver location service is running' do
      let(:data) do
        [ 
          {"id"=>"5", "latitude"=>"82", "longitude"=>"30" },
          {"id"=>"5", "latitude"=>"79", "longitude"=>"32" },
          {"id"=>"5", "latitude"=>"82", "longitude"=>"37" }
        ]
      end

      def stub_driver_location_request
        stub_request(:get, "#{ENV['DRIVER_LOCATION_SERVICE_ADDRESS']}/drivers/#{driver_id}/coordinates?minutes=#{minutes_ago}")
          .to_return(body: data.to_json, headers: {}, status: 200)
      end

      before { stub_driver_location_request }

      def action
        subject.call(driver_id, minutes_ago)
      end

      let(:response_hash) do
        {
          id: 5,
          zombie: false
        }
      end

      it { expect(action).to eq(response_hash) }
    end

    context 'driver location service is down' do
      def stub_driver_location_request
        stub_request(:get, "#{ENV['DRIVER_LOCATION_SERVICE_ADDRESS']}/drivers/#{driver_id}/coordinates?minutes=#{minutes_ago}")
          .and_raise(Errno::ECONNREFUSED.new("error"))
      end
  
      before { stub_driver_location_request }

      def action
        subject.call(driver_id, minutes_ago)
      end

      it { expect { action }.to raise_error(JsonErrorsHandler::DriverLocationServerError) }
    end

    context 'driver location service has encountered an error' do
      def stub_driver_location_request
        stub_request(:get, "#{ENV['DRIVER_LOCATION_SERVICE_ADDRESS']}/drivers/#{driver_id}/coordinates?minutes=#{minutes_ago}")
          .to_return(body: { error: 'Internal Server Error' }.to_json, headers: {}, status: 500)
      end
  
      before { stub_driver_location_request }

      def action
        subject.call(driver_id, minutes_ago)
      end

      it { expect { action }.to raise_error(JsonErrorsHandler::DriverLocationServerError) }
    end
  end
end