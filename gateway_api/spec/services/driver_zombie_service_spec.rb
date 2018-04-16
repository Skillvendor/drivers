require 'rails_helper'

describe DriverZombieService, type: :service do
  subject { DriverZombieService }
  let(:driver_id) { 5 }

  describe '.get_info(driver_id)' do
    def action
      subject.get_info(driver_id)
    end

    let(:response_hash) do
      {
        'id' => driver_id,
        'zombie' => true
      }
    end
     
    def stub_zombie_driver_request
      stub_request(:get, "#{ENV['ZOMBIE_DRIVER_SERVICE_ADDRESS']}/drivers/#{driver_id}")
        .to_return(body: response_hash.to_json , headers: {}, status: 200)
    end

    before { stub_zombie_driver_request }
    
    it 'forms the right message' do
      expect(action).to eq(response_hash)
    end
  end
end