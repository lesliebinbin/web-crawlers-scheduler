require 'docker'
Docker.options[:read_timeout] = 3600
def create_new_image(folder)
  Rails.logger.info "#{Rails.configuration.spider[:root]}/#{folder}"
  image = Docker::Image.build_from_dir("#{Rails.configuration.spider[:root]}/#{folder}") do |v|
    Rails.logger.info v
  end
  image.id.sub(/sha256:/, '')
end

def create_new_container(image_id, folder)
  Docker::Container.create('Image' => image_id, 'HostConfig' => { 'Binds' => ["#{Rails.configuration.spider[:root]}/#{folder}/:/space-platform/app/", '/dev/shm:/dev/shm'], 'Memory': (Rails.configuration.docker[:memory] * 1024 * 1024 * 1024).to_i })
                   .start!.id.sub(/sha256:/, '')
end
