class SnowFlake
  attr_reader :worker_id, :datacenter_id, :reporter, :logger, :sequence, :last_timestamp

  TWEPOCH = 1_288_834_974_657
  WORKER_ID_BITS = 5
  DATACENTER_ID_BITS = 5
  MAX_WORKER_ID = (1 << WORKER_ID_BITS) - 1
  MAX_DATACENTER_ID = (1 << DATACENTER_ID_BITS) - 1
  SEQUENCE_BITS = 12
  WORKER_ID_SHIFT = SEQUENCE_BITS
  DATACENTER_ID_SHIFT = SEQUENCE_BITS + WORKER_ID_BITS
  TIMESTAMP_LEFT_SHIFT = SEQUENCE_BITS + WORKER_ID_BITS + DATACENTER_ID_BITS
  SEQUENCE_MASK = (1 << SEQUENCE_BITS) - 1

  # note: this is a class-level (global) lock.
  # May want to change to an instance-level lock if this is reworked to some kind of singleton or worker daemon.
  MUTEX_LOCK = Monitor.new

  def initialize(worker_id = 0, datacenter_id = 0, sequence = 0, reporter = nil, logger = nil)
    raise "Worker ID set to #{worker_id} which is invalid" if worker_id > MAX_WORKER_ID || worker_id < 0
    if datacenter_id > MAX_DATACENTER_ID || datacenter_id < 0
      raise "Datacenter ID set to #{datacenter_id} which is invalid"
    end

    @worker_id = worker_id
    @datacenter_id = datacenter_id
    @sequence = sequence
    @reporter = reporter || ->(r) { puts r }
    @logger = logger || ->(r) { puts r }
    @last_timestamp = -1
    @logger.call(format('IdWorker starting. timestamp left shift %d, datacenter id bits %d, worker id bits %d, sequence bits %d, workerid %d', TIMESTAMP_LEFT_SHIFT, DATACENTER_ID_BITS, WORKER_ID_BITS, SEQUENCE_BITS, worker_id))
  end

  def get_id(*)
    # log stuff here, theoretically
    next_id.to_i
  end
  alias call get_id

  protected

  def next_id
    MUTEX_LOCK.synchronize do
      timestamp = current_time_millis
      if timestamp < @last_timestamp
        @logger.call(format('clock is moving backwards.  Rejecting requests until %d.', @last_timestamp))
      end
      if @last_timestamp == timestamp
        @sequence = (@sequence + 1) & SEQUENCE_MASK
        timestamp = till_next_millis(@last_timestamp) if @sequence == 0
      else
        @sequence = 0
      end
      @last_timestamp = timestamp
      ((timestamp - TWEPOCH) << TIMESTAMP_LEFT_SHIFT) |
        (@datacenter_id << DATACENTER_ID_SHIFT) |
        (@worker_id << WORKER_ID_SHIFT) |
        @sequence
    end
  end

  private

  def current_time_millis
    (Time.now.to_f * 1000).to_i
  end

  def till_next_millis(last_timestamp = @last_timestamp)
    loop do
      timestamp = current_time_millis
      return timestamp unless timestamp < last_timestamp

      sleep 0.0001
    end
  end
end

SNOW_FLAKE_GENERATOR = SnowFlake.new
