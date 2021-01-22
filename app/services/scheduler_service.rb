require 'rufus-scheduler'
require 'json'

# if starts from console don't started it

module SchedulerService
  class <<self
    # handle the spider creation
    def create_docker_container(mutex, scheduler)
      scheduler.every '3s', first_in: '1s' do
        if mutex.try_lock
          begin
            spider_folders = Dir.children(Rails.configuration.spider[:root]) - ['.git'] - Rails.configuration.spider[:black_list]
            spider_folders.each do |folder|
              next if Spider.find_by(name: folder)

              img_id = create_new_image(folder)
              container_id = create_new_container(img_id, folder)
              Rails.logger.info("Container created, id: #{container_id}, folder: #{folder}")
              freq = Docker::Container.get(container_id).info.dig('Config', 'Env').grep(/FREQUENCY=/)&.first.sub(
                /FREQUENCY=/, ''
              ).to_i
              Spider.create!(name: folder, image_id: img_id, container_id: container_id, status: 'Created',
                             frequency: freq || 2, max_memory: Rails.configuration.docker[:memory])
            end
          ensure
            mutex.unlock
          end

        end
      end
    end

    # remove spiders that is not active any more
    def remove_inactive_spider(mutex, scheduler)
      scheduler.every '20s', first_in: '15s' do
        if mutex.try_lock
          spider_folders = Dir.children(Rails.configuration.spider[:root]) - ['.git'] - Rails.configuration.spider[:black_list]
          begin
            Spider.each do |spider|
              Rails.logger.info spider.delete if (spider.status == 'Done') && !(spider_folders.include? spider.name)
            end
          ensure
            mutex.unlock
          end
        end
      end
    end

    # make the scheduler work again when freq gap reach

    def restart_done_spider(mutex, scheduler)
      scheduler.every '60s', first_in: '30s' do
        if mutex.try_lock
          begin
            Spider.where(status: 'Done').each do |spider|
              if (DateTime.now - JSON.parse(spider.run_info)['stop_time'].to_datetime) * 1.day > spider.frequency.day
                Docker::Container.get(spider.container_id).start
              end
            end
          ensure
            mutex.unlock
          end
        end
      end
    end

    def start_created_docker_container(mutex, scheduler)
      scheduler.every '5s', first_in: '3s' do
        if mutex.try_lock
          begin
            Spider.where(status: 'Created').each do |s|
              Docker::Container.get(s.container_id).start
            end
          ensure
            mutex.unlock
          end
        end
      end
    end

    def start_spider_program(mutex, scheduler)
      scheduler.every '20s', first_in: '10s' do
        if mutex.try_lock
          begin
            Spider.where(status: 'Ready').each do |s|
              ip_addr = Docker::Container.get(s.container_id).info.dig('NetworkSettings', 'IPAddress')
              container_obj = DRbObject.new_with_uri("druby://#{ip_addr}:9999")
              container_obj.start_crawler
            end
          ensure
            mutex.unlock
          end
        end
      end
    end

    def call
      scheduler = Rufus::Scheduler.new
      mutex = Mutex.new
      create_docker_container mutex, scheduler
      start_created_docker_container mutex, scheduler
      start_spider_program mutex, scheduler
      remove_inactive_spider mutex, scheduler
      restart_done_spider mutex, scheduler
    end
  end
end
