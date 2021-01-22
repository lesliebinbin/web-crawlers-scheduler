require 'mqtt'
module MqttHelper
  pem_keys = %i[cert_file key_file ca_file]
  conn = Rails.configuration.mqtt[:connection].map do |k, v|
    if pem_keys.include? k
      [k, Rails.root.join('private', 'mqtt', v).to_s]
    else
      [k, v]
    end
  end.to_h

  MQTT_CLIENT = MQTT::Client.connect(conn)
  class <<self
    def client
      MQTT_CLIENT
    end
  end
end
