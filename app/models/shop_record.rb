class ShopRecord < ActiveRecord::Base
  self.abstract_class = true
  self.table_name = 'shop'
  connects_to database: { writing: :shop, reading: :shop }
end
