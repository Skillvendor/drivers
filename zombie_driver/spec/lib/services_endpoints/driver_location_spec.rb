require 'rails_helper'

describe ServicesEndpoints::DriverLocation do
  subject { ServicesEndpoints::DriverLocation }

  let(:driver_id) { 5 }
  let(:minutes_ago) { 5 }

  describe '.get_position' do
    context 'driver location service is running' do
      def stub_driver_location_request
        stub_request(:get, "#{ENV['DRIVER_LOCATION_SERVICE_ADDRESS']}/drivers/#{driver_id}/coordinates?minutes=#{minutes_ago}")
          .to_return(body: "hi this is the response", headers: {}, status: 200)
      end
  
      before { stub_driver_location_request }

      def action
        subject.get_position(driver_id, minutes_ago)
      end

      it { expect(action.body).to eq('hi this is the response') }
    end

    context 'driver location service is down' do
      def stub_driver_location_request
        stub_request(:get, "#{ENV['DRIVER_LOCATION_SERVICE_ADDRESS']}/drivers/#{driver_id}/coordinates?minutes=#{minutes_ago}")
          .and_raise(Errno::ECONNREFUSED.new("error"))
      end
  
      before { stub_driver_location_request }

      def action
        subject.get_position(driver_id, minutes_ago)
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
        subject.get_position(driver_id, minutes_ago)
      end

      it { expect { action }.to raise_error(JsonErrorsHandler::DriverLocationServerError) }
    end
  end
end