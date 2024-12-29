# SimpleDash !! WIP !!

SimpleDash is simple, configurable health check dashboard Rack app for Ruby apps. It provides a web interface for monitoring system health checks and dependencies.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'simple_dash'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install simple_dash
```

## Usage

SimpleDash allows you to configure multiple dashboards to monitor different aspects of your system. Here's a basic example:

```ruby
SimpleDash.configure do |config|
  config.i18n = I18n # Optional: for translating check names
  
  # Define a dashboard named system
  config.dashboard :system do
    # Define conditions that can be reused
    condition "database.active", -> { DatabaseConnection.active? }
    condition "redis.active", -> { Redis.new.ping == "PONG" }

    # Create checks using those conditions
    check :database, conditions: ["database.active"]
    check :redis, conditions: ["redis.active"]
  end
end
```

### Mounting in Rack/Rails

Mount the dashboard in your `config.ru` or Rails routes:

```ruby
# config.ru
map '/health' do
  run SimpleDash[:system]
end

# Or in Rails routes.rb
Rails.application.routes.draw do
  mount SimpleDash[:system] => '/health'
end
```

### Internationalization

SimpleDash includes basic support for i18n. Configure your translation backend (like Rails I18n) and SimpleDash will use it to translate check names in the dashboard.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/modsognir/simple_dash.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
