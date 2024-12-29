# frozen_string_literal: true

require "rack"
require "simple_dash/config"
require "simple_dash/app"

module SimpleDash
  class << self
    def configuration
      @configuration ||= Config.new
    end

    def configure
      yield(configuration)
    end

    def [](name)
      SimpleDash::App[name]
    end
  
    def call(env)
      App.call(env)
    end
  end
end
