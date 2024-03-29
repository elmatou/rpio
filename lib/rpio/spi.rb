module Rpio
  # class for SPI interfaces on the Raspberry Pi
  class SPI
    # Least signifigant bit first, e.g. 4 = 0b001
    LSBFIRST = 0
    # Most signifigant bit first, e.g. 4 = 0b100
    MSBFIRST = 1

    # Select Chip 0
    CHIP_SELECT_0 = 0
    # Select Chip 1
    CHIP_SELECT_1 = 1
    # Select both chips (ie pins CS1 and CS2 are asserted)
    CHIP_SELECT_BOTH = 2
    # No CS, control it yourself
    CHIP_SELECT_NONE = 3

    # SPI Modes
    SPI_MODE0 = 0
    SPI_MODE1 = 1
    SPI_MODE2 = 2
    SPI_MODE3 = 3

    class << self
      #Sets the SPI mode. Defaults to mode (0,0).
      def set_mode(cpol, cpha)
        mode = SPI_MODE0 #default
        mode = SPI_MODE1 if cpol == 0 and cpha == 1
        mode = SPI_MODE2 if cpol == 1 and cpha == 0
        mode = SPI_MODE3 if cpol == 1 and cpha == 1
        Rpio.driver.spi_set_data_mode mode
      end

      #Begin an SPI block. All SPI communications should be wrapped in a block.
      def begin(chip=nil, &block)
        Rpio.driver.spi_begin
        chip = CHIP_SELECT_0 if !chip && block_given?
        spi = new(chip)

        if block.arity > 0
          block.call spi
        else
          spi.instance_exec &block
        end
      end

      # Not needed when #begin is called with a block
      def end
        Rpio.driver.spi_end
      end

      # Uses /dev/spidev0.0 to write to the SPI
      # NOTE: Requires that you have /dev/spidev0.0
      #  see: http://learn.adafruit.com/adafruit-raspberry-pi-educational-linux-distro/overview
      #  most likely requires `chmod 666 /dev/spidev0.0`
      #
      # @example Writing red, green, blue to a string of WS2801 pixels
      #   Rpio::Spi.spidev_out([255,0,0,0,255,0,0,0,255])
      #
      def spidev_out(array)
        Rpio.driver.spidev_out(array)
      end

      #Defines an event block to be called on a regular schedule. The block will be passed the slave output.
      #
      # @param [Hash] options A hash of options.
      # @option options [Fixnum] :every A frequency of time (in seconds) to poll the SPI slave.
      # @option options [Fixnum] :slave The slave number to poll.
      # @option options [Number|Array] :write Data to poll the SPI slave with.
      def poll(options, &block)
        EM::PeriodicTimer.new(options[:every]) do
          Rpio::SPI.begin options[:slave] do
            output = write options[:write]
            block.call output
          end
        end
      end

      #Defines an event block to be called when SPI slave output meets certain characteristics.
      #The block will be passed the slave output.
      #
      # @param [Hash] options A hash of options.
      # @option options [Fixnum] :every A frequency of time (in seconds) to poll the SPI slave.
      # @option options [Fixnum] :slave The slave number to poll.
      # @option options [Number|Array] :write Data to poll the SPI slave with.
      # @option options [Fixnum] :eq Tests for SPI slave output equality.
      # @option options [Fixnum] :lt Tests for SPI slave output less than supplied value.
      # @option options [Fixnum] :gt Tests for SPI slave output greater than supplied value.
      def when(options, &block)
        Rpio::SPI.poll options do |value|
          if (options[:eq] && value == options[:eq]) ||
             (options[:lt] && value < options[:lt])  ||
             (options[:gt] && value > options[:gt])
              block.call value
          end
        end
      end


    end

    def initialize(chip)
      @chip = chip
    end

    # Sets the SPI clock frequency
    def clock(frequency)
# TODO: extract diveder to CONSTANT
      options = {4000     => 0,      #4 kHz
                 8000     => 32768,  #8 kHz
                 15625    => 16384,  #15.625 kHz
                 31250    => 8192,   #31.25 kHz
                 62500    => 4096,   #62.5 kHz
                 125000   => 2048,   #125 kHz
                 250000   => 1024,   #250 kHz
                 500000   => 512,    #500 kHz
                 1000000  => 256,    #1 MHz
                 2000000  => 128,    #2 MHz
                 4000000  => 64,     #4 MHz
                 8000000  => 32,     #8 MHz
                 20000000 => 16      #20 MHz
               }
      divider = options[frequency]
      Rpio.driver.spi_clock(divider)
    end

    def bit_order(order=MSBFIRST)
      if order.is_a?(Range)
        if order.begin < order.end
          order = LSBFIRST
        else
          order = MSBFIRST
        end
      end

      Rpio.driver.spi_bit_order(order)
    end

    # Activate a specific chip so that communication can begin
    #
    # When a block is provided, the chip is automatically deactivated after the block completes.
    # When a block is not provided, the user is responsible for calling chip_select(CHIP_SELECT_NONE)
    #
    # @example With block (preferred)
    #   spi.chip_select do
    #     spi.write(0xFF)
    #   end
    #
    # @example Without block
    #   spi.chip_select(CHIP_SELECT_0)
    #   spi.write(0xFF)
    #   spi.write(0x22)
    #   spi.chip_select(CHIP_SELECT_NONE)
    #
    # @yield
    # @param [optional, CHIP_SELECT_*] chip the chip select line options
    def chip_select(chip=CHIP_SELECT_0)
      chip = @chip if @chip
      Rpio.driver.spi_chip_select(chip)
      if block_given?
        begin
          yield
        ensure
          Rpio.driver.spi_chip_select(CHIP_SELECT_NONE)
        end
      end
    end

    # Configure the active state of the chip select line
    #
    # The default state for most chips is active low.
    #
    # "active low" means the clock line is kept high during idle, and goes low when communicating.
    #
    # "active high" means the clock line is kept low during idle, and goes high when communicating.
    #
    # @param [Boolean] active_low true for active low, false for active high
    # @param [optional, CHIP_SELECT_*] chip one of CHIP_SELECT_*
    def chip_select_active_low(active_low, chip=nil)
      chip = @chip if @chip
      chip = CHIP_SELECT_0 unless chip

      Rpio.driver.spi_chip_select_polarity(chip, active_low ? 0 : 1)
    end

    # Read from the bus
    #
    # @example Read a single byte
    #   byte = spi.read
    #
    # @example Read array of bytes
    #   array = spi.read(3)
    #
    #
    # @param [optional, Number] count the number of bytes to read.
    #   When count is provided, an array is returned.
    #   When count is nil, a single byte is returned.
    # @return [Number|Array] data that was read from the bus
    def read(count=nil)
      if count
        write([0xFF] * count)
      else
        enable { Rpio.driver.spi_transfer(0) }
      end
    end

    # Write to the bus
    #
    # @example Write a single byte
    #   spi.write(0x22)
    #
    # @example Write multiple bytes
    #   spi.write(0x22, 0x33, 0x44)
    #
    # @return [Number|Array] data that came out of MISO during write
    def write(*args)
      case args.count
        when 0
          raise ArgumentError, "missing arguments"
        when 1
          data = args.first
        else
          data = args
      end

      enable do
        case data
        when Numeric
          Rpio.driver.spi_transfer(data)
        when Enumerable
          Rpio.driver.spi_transfer_bytes(data)
        else
          raise ArgumentError, "#{data.class} is not valid data. Use Numeric or an Enumerable of numbers"
        end
      end
    end

  private

    def enable(&block)
      if @chip
        chip_select(&block)
      else
        yield
      end
    end

  end
end
