# frozen_string_literal: true

require "simple_dash/dashboard"
require "simple_dash/i18n"

module SimpleDash
  class Config
    attr_writer :i18n

    def i18n
      @i18n ||= SimpleDash::I18n
    end

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
