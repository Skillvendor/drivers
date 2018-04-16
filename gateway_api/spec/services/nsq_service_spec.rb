require 'rails_helper'

describe NsqService, type: :service do
  let(:topic) { 'test-topic'}
  subject { NsqService.new(topic) }

  before { allow_any_instance_of(Nsq::Producer).to receive(:write).and_return(true) }

  describe '#publish' do
    let(:message) { 'my message' }

    def action
      subject.publish(message)
    end

    it 'enqueues the right message' do
      expect_any_instance_of(Nsq::Producer).to receive(:write).with(message)

      action
    end

    it 'returns true when it works' do
      expect(action).to eq(true)
    end
  end
end