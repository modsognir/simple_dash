require "rack"
require "simple_dash"

# Simulate some services we want to monitor
class MockServices
  def self.database_connection
    rand > 0.1
  end

  def self.database_latency
    # Simulate database response time in milliseconds
    rand(10..200)
  end

  def self.cache_service
    rand > 0.05
  end

  def self.background_jobs
    rand(0..5)
  end

  def self.api_endpoints
    # Simulate multiple API endpoints being available
    {
      users: rand > 0.05,
      orders: rand > 0.1,
      products: rand > 0.05
    }
  end

  def self.memory_usage
    # Simulate memory usage percentage
    rand(40..95)
  end

  def self.cpu_load
    # Simulate CPU load (1-minute average)
    rand(0.1..4.0)
  end
end

SimpleDash.configure do |config|
  config.dashboard :system do
    # Database health conditions
    condition "database.connected", -> {
      MockServices.database_connection
    }

    condition "database.responsive", -> {
      MockServices.database_latency < 100  # Less than 100ms
    }

    condition "database.optimal", -> {
      MockServices.database_latency < 50   # Less than 50ms
    }

    # System resource conditions
    condition "memory.available", -> {
      MockServices.memory_usage < 90  # Less than 90% used
    }

    condition "memory.healthy", -> {
      MockServices.memory_usage < 75  # Less than 75% used
    }

    condition "cpu.available", -> {
      MockServices.cpu_load < 3.0  # Load average below 3
    }

    condition "disk.space", -> {
      begin
        total_size = Dir.glob(File.join("/", "**", "*"))
          .select { |f| File.file?(f) }
          .map { |f| File.size(f) }
          .sum
        total_size < 1_000_000
      rescue
        false
      end
    }

    # Multi-condition checks
    check :database_health,
      conditions: ["database.connected", "database.responsive"]

    check :database_performance,
      conditions: ["database.connected", "database.responsive", "database.optimal"]

    check :system_resources,
      conditions: ["memory.available", "cpu.available", "disk.space"]

    check :memory_status,
      conditions: ["memory.available", "memory.healthy"]
  end

  config.dashboard :application do
    # API health conditions
    condition "api.users", -> {
      MockServices.api_endpoints[:users]
    }

    condition "api.orders", -> {
      MockServices.api_endpoints[:orders]
    }

    condition "api.products", -> {
      MockServices.api_endpoints[:products]
    }

    condition "cache.available", -> {
      MockServices.cache_service
    }

    condition "cache.warm", -> {
      MockServices.cache_service && rand > 0.2  # 80% chance cache is warm if available
    }

    condition "background_jobs.running", -> {
      MockServices.background_jobs > 0
    }

    condition "background_jobs.healthy", -> {
      jobs = MockServices.background_jobs
      jobs > 0 && jobs < 4  # Between 1-3 workers is healthy
    }

    # Multi-condition checks
    check :api_health,
      conditions: ["api.users", "api.orders", "api.products"]

    check :critical_apis,
      conditions: ["api.users", "api.orders"]

    check :cache_health,
      conditions: ["cache.available", "cache.warm"]

    check :worker_health,
      conditions: ["background_jobs.running", "background_jobs.healthy"]
  end
end

RackExample = Rack::Builder.new do
  map "/health/system" do
    run SimpleDash[:system]
  end

  map "/health/app" do
    run SimpleDash[:application]
  end

  map "/" do
    run ->(env) {
      [200, {"content-type" => "text/html"}, ["Hello from Rack!"]]
    }
  end
end
