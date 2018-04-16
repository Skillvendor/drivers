require 'sidekiq/api'

Sidekiq.configure_client do |config|
  Rails.application.config.after_initialize do
    Sidekiq::Queue.new("consumer_queue").clear
    Drivers::ConsumerWorker.perform_async
  end
end