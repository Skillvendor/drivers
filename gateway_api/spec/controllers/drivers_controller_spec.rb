require 'rails_helper'

describe 'DriversController', type: :request do
  describe 'PUT /drivers/:id' do
    context 'valid request' do
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
        api_put "/drivers/#{params[:id]}", params
      end

      context 'nsq works' do
        before(:each) do
          allow_any_instance_of(Nsq::Producer).to receive(:write).and_return(true)
          Timecop.freeze(spec_time)
        end

        it 'returns 200 if the request is valid' do
          action

          expect(response.status).to eq(200)
        end

        it 'enqueues a message' do
          expect_any_instance_of(Nsq::Producer).to receive(:write).with(params.to_json)
          
          action
        end
      end

      context 'nsq is down' do
        before { allow_any_instance_of(Nsq::Producer).to receive(:initialize).and_raise(Errno::ECONNREFUSED.new) }
        
        it 'responds with 500' do
          action

          expect(response.status).to eq(500)
        end

        it 'responds with internal server error' do
          action

          expect(JSON.parse(response.body)['errors'].first['title']).to eq('Internal Server Error')
        end
      end
    end
  end

  describe 'GET /drivers/:id' do
    let(:driver_id) { 5 }

    def action
      api_get "/drivers/#{driver_id}"
    end

    context 'zombie server is up' do
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

      before(:each) do
        stub_zombie_driver_request
        action
      end

      it 'forwards the response' do
        data = JSON.parse(response.body)

        expect(data).to eq(response_hash)
      end
    end

    context 'zombie server is down' do
      def stub_zombie_driver_request
        stub_request(:get, "#{ENV['ZOMBIE_DRIVER_SERVICE_ADDRESS']}/drivers/#{driver_id}")
          .and_raise(Errno::ECONNREFUSED.new("error"))
      end

      before(:each) do
        stub_zombie_driver_request
        action
      end

      it 'responds with error' do
        result = JSON.parse(response.body)
        expect(result).to eq({"errors"=>[{"title"=>"Zombie Driver is not responding"}]})
      end
    end

    context 'zombie server can\'t respond' do
      def stub_zombie_driver_request
        stub_request(:get, "#{ENV['ZOMBIE_DRIVER_SERVICE_ADDRESS']}/drivers/#{driver_id}")
          .and_return(body: { error: 'Internal Server Error' }.to_json, headers: {}, status: 500)
      end

      before(:each) do
        stub_zombie_driver_request
        action
      end

      it 'responds with error' do
        result = JSON.parse(response.body)
        expect(result).to eq({"errors"=>[{"title"=>"Zombie Driver is not responding"}]})
      end
    end
  end
end