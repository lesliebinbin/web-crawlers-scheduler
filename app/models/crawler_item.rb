class CrawlerItem
  include Mongoid::Document
  store_in collection: 'crawler_items', database: 'web_crawler'
  field :item, type: Hash
  field :name, type: String
end
