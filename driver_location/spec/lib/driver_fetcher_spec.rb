require 'rails_helper'

describe DriverFetcher do
  let(:driver_id) { 5 }
  let(:driver_cache_key) { "driver_#{driver_id}" }

  subject { DriverFetcher.new(driver_id) }

  before { Rails.cache.write(driver_cache_key, 'random message') }

  after { Rails.cache.clear }

  describe '.call' do
    def action
      subject.call
    end

    it { expect(action).to eq('random message') }
  end
end