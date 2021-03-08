# Container Config

`ContainerConfig` loads values from environment variables, secrets, application credentials, and any other desired value sources within Ruby applications. Rails is not required, but this gem will integrate with Rails if it is available.

## Installation

Add this line to your application"s Gemfile:

```ruby
gem "container_config"
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install container_config

## Usage

```ruby
# Retrieve the value of the POSTGRES_USER environment variable, secret mount, or Rails credential
ContainerConfig.load("POSTGRES_USER")

# Retrieve the value of the POSTGRES_PORT environment variable, secret mount, or Rails credential as an integer with a default value of 5432
ContainerConfig.load("POSTGRES_PORT", type: :integer, default: 5432)

# Retrieve the value of the POSTGRES_PASSWORD environment variable, secret mount, or Rails credential and raise an exception if it cannot be found
ContainerConfig.load("POSTGRES_PASSWORD", required: true)
```

Full documentation is available in the [ContainerConfig GitHub Pages](https://wheatevo.github.io/container_config/).

### Extending ContainerConfig

`ContainerConfig` may be extended by adding more value providers to gather configuration data or by adding more type coercers to coerce retrieved data into desired types.

#### Value Providers

More value providers may be added by creating a new class that inherits from `ContainerConfig::Provider::Base` and implementing the `name` and `load` methods. The `name` method should return a `String` name for your value provider and the `load` method should receive a `String` `key`, `*dig_keys`, and `**options` and return the found value or `nil`.

You may optionally call `super` from `load` to enable logging by default.

```ruby
# Define a new value provider that returns the abstract from a DuckDuckGo instant result search (https://duckduckgo.com/api)
require "container_config"
require "uri"
require "net/http"
require "json"

class DuckDuckGoAbstractProvider < ContainerConfig::Provider::Base
  def name
    "DuckDuckGo Wikipedia abstract provider"
  end

  def load(key, *dig_keys, **options)
    super
    
    response = Net::HTTP.get(URI.parse("https://api.duckduckgo.com/?q=#{URI.encode_www_form([key])}&format=json"))
    JSON.parse(response)["Abstract"]
  end
end

# Add the DuckDuckGo value provider to the array of existing providers
ContainerConfig.providers << DuckDuckGoAbstractProvider.new

# Use the DuckDuckGo value provider
ContainerConfig.load("rockhopper penguins")
# => "The rockhopper penguins are three closely related taxa of crested penguins..."
```

#### Type Coercers

More supported types may be added by creating a new class that inherits from `ContainerConfig::Coercer::Base` and implementing the `name`, `type`, and `coerce` methods. The `name` method should return a `String` name for your type coercer, the `type` method should return a `Symbol` type for your type coercer, and the `coerce` method should receive a single `Object` `value` and return your coerced type.

```ruby
# Define a new type coercer that simply prepends "MyType: " to the string representation of a value
require "container_config"

class MyTypeCoercer < ContainerConfig::Coercer::Base
  def name
    "My Type"
  end

  def type
    :my_type
  end

  def coerce(value)
    "MyType: #{value}"
  end
end

# Add the type coercer to the array of existing type coercers
ContainerConfig.coercers << MyTypeCoercer.new

# Use the type coercer (KEY has value "key_value")
ContainerConfig.load("KEY", type: :my_type)
# => "MyType: key_value"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/wheatevo/container_config.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
