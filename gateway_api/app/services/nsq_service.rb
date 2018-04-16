require 'nsq'

class NsqService
  attr_accessor :producer, :topic

  def initialize(topic)
    @topic = topic
    @producer = producer
  end

  def publish(message)
    status = @producer.write(message)

    status ? true : false
  end

  def terminate
    @producer.terminate
  end

  private

  def producer
    Nsq::Producer.new(
      nsqd: nsqd,
      topic: @topic
    )
  end

  def nsqd
    ENV['NSQ_ADDRESS']
  end
end