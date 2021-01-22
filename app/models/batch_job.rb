class BatchJob
  include Mongoid::Document
  store_in collection: 'batch_jobs', database: 'web_crawler'
  field :job_id, type: Integer
  field :count, type: Integer
  field :item_type, type: String
  field :items, type: Array
  field :status, type: Integer
  field :es_index, type: String
  field :name, type: String
  field :error_info, type: Hash
  field :action, type: String
  field :client_id, type: Integer
  field :index_id, type: Integer
end
