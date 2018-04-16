require 'rails_helper'

describe 'DriversController', type: :request do
  describe 'GET /drivers/:id' do
    let(:driver_id) { 5 }
    let(:driver_cache_key) { "driver_#{driver_id}" }
    let(:minutes) { 5 }
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
  
    before do 
      Timecop.freeze(spec_time)
    end

    def action
      api_get "/drivers/#{driver_id}/coordinates?minutes=#{minutes}"
    end

    context 'valid request' do
      before do
        Rails.cache.write(driver_cache_key, data)
        action
      end

      it 'forwards the response' do
        data = JSON.parse(response.body)

        expect(data).to eq(selected_data)
      end
    end

    context 'requesting a driver that doesn\'t exist' do
      before do
        Rails.cache.clear
      end

      it 'raises an error' do
        action
        data = JSON.parse(response.body)

        expect(data).to eq({"errors"=>[{"title"=>"Resource Not Found"}]})
      end
    end
  end
end