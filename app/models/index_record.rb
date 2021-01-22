class IndexRecord < ActiveRecord::Base
  self.abstract_class = true
  self.table_name = 'index'
  connects_to database: { writing: :admin, reading: :admin }
end
