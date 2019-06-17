RSpec.describe Rpio::I2C do

  before(:context) do
    Rpio.driver = Rpio::StubDriver::Base
  end

  describe 'clock setting' do
    it 'should check driver settings' do
      expect(Rpio.driver).to receive(:i2c_allowed_clocks).and_return([100*10**3])
      Rpio::I2C.clock = 100*10**3
    end

    it 'should accept 100 kHz' do
      expect(Rpio.driver).to receive(:i2c_allowed_clocks).and_return([100*10**3])
      expect(Rpio.driver).to receive(:i2c_set_clock).with(100*10**3)
      Rpio::I2C.clock = 100*10**3
    end

    it 'should not accept 200 kHz' do
      expect(Rpio.driver).to receive(:i2c_allowed_clocks).and_return([100*10**3])
      expect { Rpio::I2C.clock = 200*10**3 }.to raise_error ArgumentError
    end
  end

  xdescribe 'when in block' do
    it 'should call i2c_begin' do
      expect(Rpio.driver).to receive(:i2c_begin)
      Rpio::I2C.begin {}
    end

    it 'should call i2c_end' do
      expect(Rpio.driver).to receive(:i2c_end)
      Rpio::I2C.begin {}
    end

    it 'should call i2c_end even after raise' do
      expect(Rpio.driver).to receive(:i2c_end)
      begin
        Rpio::I2C.begin { raise 'OMG' }
      rescue
      end
    end

    xdescribe 'write operation' do
      it 'should set address' do
        expect(Rpio.driver).to receive(:i2c_set_address).with(4)
        Rpio::I2C.begin do
          write to: 4, data: [1, 2, 3, 4]
        end
      end

      it 'should pass data to driver' do
        expect(Rpio.driver).to receive(:i2c_transfer_bytes).with([1, 2, 3, 4])
        Rpio::I2C.begin do
          write to: 4, data: [1, 2, 3, 4]
        end
      end
    end
  end
end
