module Drivers
  class ConsumerWorker
    include Sidekiq::Worker
    sidekiq_options :queue => :consumer_queue, :retry => 10

    def perform
      StoreDriversService.call
    end
  end
end