require "simple_dash/dashboard"

module SimpleDash
  class Config
    attr_accessor :i18n

    def dashboards
      @dashboards ||= {}
    end

    def dashboard(name, &block)
      dashboards[name.to_s] = Class.new(Dashboard, &block)
      dashboards[name.to_s].name = name
      dashboards[name.to_s]
    end
  end
end
