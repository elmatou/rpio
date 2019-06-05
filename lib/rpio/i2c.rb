module Rpio
  class I2C

    class << self
      def clock=(clock)
        Rpio.driver.i2c_set_clock clock
      end

      def open(address, &block)
        instance = Rpio::I2C.new(address)
        begin
          if block.arity > 0
            block.call instance
          else
            instance.instance_exec &block
          end
        ensure
          close
        end
      end

      def close
        Rpio.driver.i2c_end if ObjectSpace.each_object(self).count <= 0
      end


    end

    def initialize(address)
      raise ArgumentError, 'Address must be between 0x03 & 0x77' unless (0x03..0x77).include? address
      @address = address
      Rpio.driver.i2c_begin
    end

    def write(register, data)
      case data
        # when Fixnum then data = [data]
        when Enumerable then data = data.pack('C*')
        when String then nil
        else raise ArgumentError, "data must be enumerable or a string"
      end
      Rpio.driver.i2c_block_write @address, register, data
    end

    def read(register = nil, bytes = 1)
      Rpio.driver.i2c_block_read(@address, register, bytes).unpack('C*')
    end

    def read_8bits(register)
      read(register, 1).first
    end

    def read_16bits(register)
      read(register, 2).inject(0x00) {|memo, i| (memo << 8) + i }
    end

  end
end
