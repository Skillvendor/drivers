require 'rails_helper'

describe ServicesEndpoints::ZombieDriver do
  subject { ServicesEndpoints::ZombieDriver }

  describe '.check_zombification' do
    let(:driver_id) { 5 }

    def action
      subject.check_zombification(driver_id)
    end

    context 'zombie driver service works normally' do
      def stub_zombie_driver_request
        stub_request(:get, "#{ENV['ZOMBIE_DRIVER_SERVICE_ADDRESS']}/drivers/#{driver_id}")
          .to_return(body: "hi this is the response", headers: {}, status: 200)
      end

      before { stub_zombie_driver_request }

      it { expect(action.body).to eq('hi this is the response') }
    end

    context 'zombie driver service is down' do
      def stub_driver_location_request
        stub_request(:get, "#{ENV['ZOMBIE_DRIVER_SERVICE_ADDRESS']}/drivers/#{driver_id}")
          .and_raise(Errno::ECONNREFUSED.new)
      end
  
      before { stub_driver_location_request }

      it { expect { action }.to raise_error(JsonErrorsHandler::ZombieDriverServerError) }
    end

    context 'zombie driver service has encountered an error' do
      def stub_driver_location_request
        stub_request(:get, "#{ENV['ZOMBIE_DRIVER_SERVICE_ADDRESS']}/drivers/#{driver_id}")
          .and_return(body: { error: 'Internal Server Error' }.to_json, headers: {}, status: 500)
      end
  
      before { stub_driver_location_request }

      it { expect { action }.to raise_error(JsonErrorsHandler::ZombieDriverServerError) }
    end
  end
end