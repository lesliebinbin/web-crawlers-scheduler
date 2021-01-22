unless defined?(Rails::Console)
  MqttService.call
  # SchedulerService.call
end
