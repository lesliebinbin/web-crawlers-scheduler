class Spider
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'spiders', database: 'web_crawler'
  field :name, type: String
  field :container_id, type: String
  field :status, type: String
  field :image_id, type: String
  field :prefix, type: String
  field :frequency, type: Integer
  field :run_info, type: String
  field :max_memory, type: Float, default: 1
end
