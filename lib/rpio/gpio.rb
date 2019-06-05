module Rpio
  # Represents a GPIO pin on the Raspberry Pi
  class Gpio

    GPIO_HIGH = 1
    GPIO_LOW  = 0

    class << self
      #Defines an event block to be executed when an pin event occurs.
      #
      # == Parameters:
      # options:
      #   Options hash. Options include `:pin`, `:invert` and `:trigger`.
      #
      def watch(options, &block)
        new_thread = Thread.new do
          pin = Rpio::Gpio.new(options)
          loop do
            pin.wait_for_change
            if block.arity > 0
              block.call pin
            else
              pin.instance_exec &block
            end
          end
        end
        new_thread.abort_on_exception = true
        new_thread
      end

      #Defines an event block to be executed after a pin either goes high or low.
      #
      # @param [Hash] options A hash of options
      # @option options [Fixnum] :pin The pin number to initialize. Required.
      # @option options [Symbol] :goes The event to watch for. Either :high or :low. Required.
      def after(options, &block)
        options[:trigger] = options.delete(:goes) == :high ? :rising : :falling
        watch options, &block
      end

    end

    attr_reader :pin, :last_value, :options

    #Initializes a new GPIO pin.
    #
    # @param [Hash] options A hash of options
    # @option options [Fixnum] :pin The pin number to initialize. Required.
    #
    # @option options [Symbol] :direction The direction of communication,
    # either :in or :out. Defaults to :in.
    #
    # @option options [Boolean] :invert Indicates if the value read from the
    # physical pin should be inverted. Defaults to false.
    #
    # @option options [Symbol] :trigger Indicates when the wait_for_change
    # method will detect a change, either :rising, :falling, or :both edge
    # triggers. Defaults to :both.
    #
    # @option options [Symbol] :pull Indicates if and how pull mode must be
    # set when pin direction is set to :in. Either :up, :down or :offing.
    # Defaults to :off.
    #
    def initialize(options)
      @options = {:direction => :in,
                  :invert => false,
                  :trigger => :none,
                  :pull => :off,
                }.merge(options)

      raise ArgumentError, 'Pin # required' unless @options[:pin]

      Rpio.driver.gpio_direction(@options[:pin], @options[:direction])
      Rpio.driver.gpio_set_trigger(@options[:pin], @options[:trigger])
      if @options[:direction] == :out && @options[:pull] != :off
        raise ArgumentError, 'Unable to use pull-ups : pin direction must be :in for this'
      else
        Rpio.driver.gpio_set_pud(@options[:pin], @options[:pull])
      end
      read
    end

    # If the pin has been initialized for output this method will set the
    # logic level high.
    def on
      Rpio.driver.gpio_write(@options[:pin], GPIO_HIGH) if @options[:direction] == :out
    end

    # Tests if the logic level is high.
    def on?
      not off?
    end

    # If the pin has been initialized for output this method will set
    # the logic level low.
    def off
      Rpio.driver.gpio_write(@options[:pin], GPIO_LOW) if @options[:direction] == :out
    end

    # Tests if the logic level is low.
    def off?
      value == GPIO_LOW
    end

    def value
      @value ||= read
    end

    # If the pin has been initialized for output this method will either raise
    # or lower the logic level depending on `new_value`.
    # @param [Object] new_value If false or 0 the pin will be set to off, otherwise on.
    def update_value(new_value)
      !new_value || new_value == GPIO_LOW ? off : on
    end
    alias_method :value=, :update_value

    # Tests if the logic level has changed since the pin was last read.
    def changed?
      last_value != value
    end

    # Blocks until a logic level change occurs. The initializer option
    # `:trigger` modifies what edge this method will release on.
    def wait_for_change
      Rpio.driver.gpio_wait_for(@options[:pin])
    end

    # Reads the current value from the pin. Without calling this method
    # first, `value`, `last_value` and `changed?` will not be updated.
    #
    # In short, you must call this method if you are curious about the
    # current state of the pin.
    def read
      val = Rpio.driver.gpio_read(@options[:pin])
      @last_value = @value
      @value = @options[:invert] ? (val ^ 1) : val
    end

  private
    def method_missing(method, *args, &block)
      Rpio.driver.send(method, @options[:pin], *args, &block)
    end
  end
end
