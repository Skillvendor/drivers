require 'rails_helper'

describe NsqConsumerService, type: :service do
  let(:topic) { 'test-topic'}
  let(:message_struct) { Struct.new(:body) }
  let(:message) { 'random message' }

  subject { NsqConsumerService.new(topic) }

  describe '#call' do
    def action
      subject.call
    end

    context 'when nsq works' do
      before { allow_any_instance_of(Nsq::Consumer).to receive(:pop_without_blocking).and_return(message_struct.new(message)) }

      it 'retrieves the message' do
        expect(action).to eq(message)
      end
    end
  end
end