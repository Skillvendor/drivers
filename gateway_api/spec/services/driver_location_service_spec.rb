require 'rails_helper'

describe DriverLocationService, type: :service do
  subject { DriverLocationService }

  describe '#create_nsq_message' do
    def spec_time
      DateTime.parse('2018-05-16 20:54:32')
    end

    let(:params) do 
      { 
        id: '5',
        latitude: '44.5',
        longitude: '33.4',
        updated_at: spec_time
      }
    end

    def action
      subject.create_nsq_message(params.merge!({random_param: 'why not?'}))
    end

    before(:each) do
      allow_any_instance_of(Nsq::Producer).to receive(:write).and_return(true)
      Timecop.freeze(spec_time)
    end
    
    it 'enqueues the right message' do
      expect_any_instance_of(Nsq::Producer).to receive(:write).with(params.to_json)

      action
    end
  end
end