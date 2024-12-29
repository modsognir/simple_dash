# frozen_string_literal: true

require_relative "lib/simple_dash/version"

Gem::Specification.new do |spec|
  spec.name = "simple_dash"
  spec.version = SimpleDash::VERSION
  spec.authors = ["Jared Fraser"]
  spec.email = ["dev@jsf.io"]

  spec.summary = "A simple, configurable health check dashboard for Ruby applications"
  spec.description = "SimpleDash provides a simple web interface for monitoring system health checks. It supports custom conditions, i18n, and multiple dashboard configurations."
  spec.homepage = "https://github.com/modsognir/simple_dash"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/modsognir/simple_dash"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rack"
  spec.add_dependency "condition_checker"
end
