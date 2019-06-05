require "rpio/version"

require 'rpio/gpio'
require 'rpio/i2c'
require 'rpio/spi'
require 'rpio/pwm'

require 'rpio/stub_driver'

module Rpio
  extend self

  #Defines an event block to be executed when an pin event occurs.
  #
  # @param [Rpio::Driver] a Rpio::Driver subclass to load
  # and use with all Rpio objects.
  #
  def driver=(klass)
    if !klass.nil? && (klass <= Rpio::StubDriver::Base)
      @driver.close if @driver
      @driver = klass.new
    else
      raise ArgumentError, 'Supply a Rpio::Driver::Base subclass for driver'
    end
  end

  #Returns the loaded driver.
  #
  def driver
    @driver ||= Rpio::StubDriver::Base.new
  end

  at_exit { driver.close }

  #Prevents the main thread from exiting.
  # @deprecated Please use EventMachine.run or any other thing instead.
  def wait
    loop do sleep 1 end
  end
end
