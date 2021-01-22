require 'jimson'

class SyncHandler
  extend Jimson::Handler

  def sum(a, b)
    a + b
  end
end

SyncApp =  Jimson::Server.new(SyncHandler.new)
