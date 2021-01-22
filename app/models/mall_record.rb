class MallRecord < ActiveRecord::Base
  self.abstract_class = true
  self.table_name = 'mall'
  connects_to database: { writing: :mall, reading: :mall }
end
