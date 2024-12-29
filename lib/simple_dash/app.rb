module SimpleDash
  class App
    attr_accessor :name, :dashboard

    def initialize(dashboard:)
      @dashboard = dashboard || SimpleDash.configuration.dashboards[nil]
    end

    def self.call(env)
      raise "Use SimpleDash::App['dashboard_name'] instead"
    end

    def self.[](name = nil)
      app = new(dashboard: SimpleDash.configuration.dashboards[name.to_s])
      ->(env) { app.call(env) }
    end

    def call(env)
      req = Rack::Request.new(env)

      case req.path
      when "/"
        config = SimpleDash.configuration
        body = ERB.new(File.read("app/views/simple_dash/index.html.erb")).result(binding)
        [200, {"Content-Type" => "text/html"}, [body]]
      else
        [404, {"Content-Type" => "text/html"}, ["Not Found"]]
      end
    end
  end
end
