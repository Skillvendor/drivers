require 'rails_helper'

describe CoordinatesExtractionService, type: :service do
  let(:driver_id) { 5 }
  let(:driver_cache_key) { "driver_#{driver_id}" }
  let(:minutes_ago) { 5 }
  def spec_time
    DateTime.parse('2018-05-16 20:54:32')
  end
  let(:selected_data) do
    [
      {"id"=>"5", "latitude"=>"82", "longitude"=>"30", "updated_at" => (spec_time - 5.minutes).to_s },
      {"id"=>"5", "latitude"=>"82", "longitude"=>"30", "updated_at" => (spec_time - 30.seconds).to_s},
      {"id"=>"5", "latitude"=>"79", "longitude"=>"32", "updated_at" => (spec_time).to_s },
    ]
  end
  let(:data) do
    [
      {"id"=>"5", "latitude"=>"82", "longitude"=>"30", "updated_at" => (spec_time - 7.minute).to_s },
      *selected_data,
      {"id"=>"5", "latitude"=>"79", "longitude"=>"32", "updated_at" => (spec_time - 6.minutes).to_s }
    ]
  end

  let(:fetcher) { DriverFetcher.new(driver_id) }
  subject { CoordinatesExtractionService.new(fetcher, minutes_ago) }

  before { Timecop.freeze(spec_time) }

  describe '#call' do
    def action
      subject.call
    end

    before { Rails.cache.write(driver_cache_key, data) }

    it { expect(action).to eq(selected_data)  }
  end
end