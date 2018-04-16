require 'rails_helper'

describe StoreDataService, type: :service do
  let(:data) do
    { test: 'test' }
  end
  let(:key) { 'test-key' }

  subject { StoreDataService }

  describe '#call' do
    def action(data)
      subject.new(data, key).call
    end

    after { Rails.cache.clear }

    it 'writes the data in the rails cache' do
      action(data)

      expect(Rails.cache.read(key)).to eq([ data ])
    end

    it 'appends data if data already exists' do
      Rails.cache.write(key, [data])
      action(data)

      expect(Rails.cache.read(key)).to eq([ data, data ])
    end
  end
end