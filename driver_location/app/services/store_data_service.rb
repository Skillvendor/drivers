class StoreDataService
  attr_accessor :data, :key

  def initialize(data, key)
    @data = data
    @key = key
  end

  def call
    cached_data = Rails.cache.read(@key)

    Rails.cache.write(@key, [@data, *cached_data])
  end
end