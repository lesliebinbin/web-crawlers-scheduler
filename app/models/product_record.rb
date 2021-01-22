class ProductRecord < ActiveRecord::Base
  self.abstract_class = true
  self.table_name = 'brand_product'
  connects_to database: { writing: :brand, reading: :brand }
  alias_attribute :client_id, :product_id
  alias_attribute :name, :product_name
end
