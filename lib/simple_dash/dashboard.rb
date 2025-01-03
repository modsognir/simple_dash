require "condition_checker"

module SimpleDash
  class Dashboard
    class << self
      attr_writer :name

      def name
        @name || "simple_dash.dashboard"
      end
    end

    include ConditionChecker::Mixin
  end
end
