require 'nsq'

class NsqConsumerService
  attr_accessor :consumer, :topic, :msg

  def initialize(topic)
    @topic = topic
    @consumer = consumer
  end

  def call
    @msg = @consumer.pop_without_blocking

    @msg ? @msg.body : nil
  end

  def finished_processing_msg
    @msg.finish if @msg
  end

  def terminate
    @consumer.terminate
  end

  private

  def consumer
    Nsq::Consumer.new(
      nsqlookupd: nsqlookupd,
      topic: @topic,
      channel: 'driver-location'
    )
  end

  def nsqlookupd
    ENV['NSQ_LOOKUP_ADDRESS']
  end
end