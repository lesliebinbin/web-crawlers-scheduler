# handle msg channels, unless it starts with Console
require 'space/mqtt-helper'
require 'space/docker-helper'
require 'space/notify-helper'
require 'space/mqtt-helper'
require 'space/snow_flake'
require 'drb/drb'
require 'monitor'
class MqttService
  GLOBAL_MONITOR = Monitor.new
  class <<self
    def get_action_and_id(parent, child_record, **opts)
      result = child_record.find_by(opts.merge("#{parent.class.name.downcase.gsub(/record/,
                                                                                  '')}_id".to_sym => parent[:client_id]))
      result.nil? ? ['INSERT', SNOW_FLAKE_GENERATOR.get_id] : ['UPDATE', result[:client_id]]
    end

    def shop_es_index(name)
      mall = MallRecord.find_by(name: name)
      mall.nil? ? "mall-shop-#{SNOW_FLAKE_GENERATOR.get_id}" : mall[:alias]
    end

    def brand_product_es_index(name)
      brand = BrandRecord.find_by(name: name.gsub(/-/, ' '))
      brand.nil? ? "brand-product-#{SNOW_FLAKE_GENERATOR.get_id}" : "brand-product-#{brand[:client_id]}"
    end

    def event_es_index(_)
      'space-events'
    end

    def get_es_index(item_type, name)
      send("#{item_type}_es_index", name)
    end

    def get_parent_and_child(item_type, name)
      case item_type
      when 'shop'
        [MallRecord.find_by(name: name), ShopRecord]
      when 'brand_product'
        [BrandRecord.find_by(name: name.gsub(/-/, ' ')), ProductRecord]
      when 'event'
        [nil, nil]
      end
    end

    def create_and_submit_jobs(item_type, name)
      GLOBAL_MONITOR.synchronize do
        parent, child_record = get_parent_and_child(item_type, name)
        parent_action, parent_id = if parent.nil?
                                     ['INSERT',
                                      SNOW_FLAKE_GENERATOR.get_id]
                                   else
                                     ['UPDATE', parent[:client_id]]
                                   end
        items = []
        if parent.nil?
          CrawlerItem.where(name: name)
                     .map(&:item)
                     .each do |item|
            item.delete(:name)
            items << (if item_type == 'brand_product'
                        { action: 'INSERT', product_id: SNOW_FLAKE_GENERATOR.get_id }.merge(item: item)
                      else
                        { action: 'INSERT', client_id: SNOW_FLAKE_GENERATOR.get_id }.merge(item: item)
                      end)
          ensure
            next
          end
        else
          CrawlerItem.where(name: name)
                     .map(&:item)
                     .each do |item|
            item.delete(:name)
            action, client_id = get_action_and_id(parent, child_record, name: item[:title])
            items << (if item_type == 'brand_product'
                        { action: action, product_id: client_id }.merge(item: item)
                      else
                        { action: action, client_id: client_id }.merge(item: item)
                      end)
          ensure
            next
          end
        end
        index_record = IndexRecord.find_by(client_id: parent_id, type: item_type)
        index_id = index_record.nil? ? -1 : index_record[:index_id]
        items.each_slice(1000).each do |sub_items|
          BatchJob.create!(job_id: SNOW_FLAKE_GENERATOR.get_id,
            count: sub_items.size,
            action: parent_action,
            client_id: parent_id,
            item_type: item_type,
            items: sub_items,
            index_id: index_id,
            status: 0,
            name: name.gsub(/-/, ' '),
            es_index: get_es_index(item_type, name))
        end

        CrawlerItem.delete_all(name: name)
      end
    end

    def handle_status_change(message)
      item_type, name, container_id, status, run_info = JSON.parse(message, symbolize_names: true).values_at(
        :item_type,
        :name, :container_id,
        :status, :run_info
      )
      Spider.find_by(name: name, container_id: container_id)&.update(status: status, run_info: run_info.to_json)
      if status == 'Done'
        Docker::Container.get(container_id).stop
        Thread.new do
          create_and_submit_jobs(item_type, name)
        end
      end
      notify(run_info) unless run_info.nil?
    end

    def handle_data_income(message)
      crawler_item = JSON.parse(message)
      CrawlerItem.create!(crawler_item)
    end

    def handle_wiki(message)
      name, wiki_link = JSON.parse(message)
      WikiLink.find_or_create_by(name: name)
      WikiLink.update(wiki_link: wiki_link)
    end

    def handle_mqtt_channels
      data_topic, status_topic, wiki_topic = Rails.configuration.mqtt[:topics].values_at('data', 'status', 'wiki')
      MqttHelper.client.subscribe(data_topic)
      MqttHelper.client.subscribe(status_topic)
      MqttHelper.client.subscribe(wiki_topic)
      Thread.new do
        MqttHelper.client.get do |topic, message|
          case topic
          when status_topic
            handle_status_change(message)
          when data_topic
            handle_data_income(message.encode('UTF-8', invalid: :replace, undef: :replace))
          when wiki_topic
            handle_wiki(message)
          end
        rescue StandardError => e
          Rails.logger.error e.message
          Rails.logger.error topic
          Rails.logger.error message
        end
      end
    end

    def call
      handle_mqtt_channels
    end
  end
end
