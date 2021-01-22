require 'rest-client'
require 'json'
require 'erb'
RENDER = ERB.new(
  <<~MY_ERB
    <h1>Spider Alert</h1>
    <ul>
        <li>Spider Name: <%= @spider_name %></li>
        <li>Start Time: <%= @start_time %></li>
        <li>Stop Time: <%= @stop_time %></li>
        <li>Items Sent: <%= @sent %></li>
        <li>Items processed: <%= @processed %></li>
        <li>Error: <%= h(@current_error) %></li>
    </ul>
  MY_ERB
)

class Notification
  include ERB::Util
  attr_accessor :spider_name, :start_time, :stop_time, :sent, :processed, :current_error
  def initialize
    yield self if block_given?
  end

  def get_binding
    binding
  end
end

def notify(msg)
  notification = Notification.new do |nc|
    nc.spider_name, nc.start_time, nc.stop_time, nc.current_error = msg.values_at(:spider_name, :start_time, :stop_time, :error)
    nc.sent, nc.processed = msg.dig(:visits).values_at(:requests, :responses)
  end
  RestClient.post Rails.configuration.web_hook[:url], { text: RENDER.result(notification.get_binding) }.to_json, { content_type: :json, accept: :json }
end
