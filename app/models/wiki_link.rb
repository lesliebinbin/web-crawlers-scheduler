class WikiLink
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'wiki_link', database: 'web_crawler'
  field :name, type: String
  field :wiki_link, type: String
end
