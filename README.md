# Rpio

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/rpio`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rpio'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rpio

## Usage

Rpio permit to communicate through a set of line. Currently are implemented, Gpio, I2C, SPI, ...

Rpio needs a driver to work, the driver is plateform specific and implement all or every
You have to choose one, and declare it as a dependency.

your gemfile would look like

```ruby
gem 'rpio'
gem 'rpio-sysfs'
```


### Gpio
Represent the general purpose pin of a Raspberry Pi very similar to PiPiper::Pin

```ruby
p = Rpio::Gpio.new pin: 26, direction: :out
p.on
p.off?

or

Rpio::Gpio.watch :pin => 26, :trigger => :falling do
  ... do some thing
end

```

### I2C

### SPI

### PWM

### OneWire
not ready Yet !

### Drivers
Currently two drivers are available, but it is very easy to build a new one.
#### Sysfs
```ruby
gem 'rpio-sysfs'
```
check the repos for more details : https://github.com/elmatou/rpio-sysfs

#### Bcm2835
```ruby
gem 'rpio-bcm2835'
```
check the repos for more details : https://github.com/elmatou/rpio-bcm2835

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Build a new drivers
You can use the Rpio::StubDriver as a skeleton.
We use it as a stub for the tests of Rpio ans it is the reference for the API

https://github.com/elmatou/rpio-stub_driver

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/rpio.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
