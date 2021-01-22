class BrandRecord < ActiveRecord::Base
  self.abstract_class = true
  self.table_name = 'brand'
  connects_to database: { writing: :brand, reading: :brand }
end
