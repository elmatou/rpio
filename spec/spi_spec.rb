require_relative 'spec_helper'

RSpec.describe Rpio::SPI do

  before(:context) do
    Rpio.driver = Rpio::StubDriver::Base
  end

  xit '#poll(options, &block)'
  xit '#when(options, &block)'

  describe 'when in block' do
    it 'should call spi_begin' do
      expect(Rpio.driver).to receive(:spi_begin)
      Rpio::SPI.begin {}
    end

    it 'should call spi_chip_select to set and unset chip' do
      expect(Rpio.driver).to receive(:spi_chip_select).with(Rpio::SPI::CHIP_SELECT_1)
      expect(Rpio.driver).to receive(:spi_chip_select).with(Rpio::SPI::CHIP_SELECT_NONE)

      Rpio::SPI.begin(Rpio::SPI::CHIP_SELECT_1) do
        read
      end
    end
  end

  describe 'set mode' do
    it 'should call spi_set_data_mode' do
      expect(Rpio.driver).to receive(:spi_set_data_mode).with(Rpio::SPI::SPI_MODE3)
      Rpio::SPI.set_mode(1, 1)
    end
  end

  describe '#spidev_out' do
    it 'should attempt to write data to spi' do
      expect(Rpio.driver).to receive(:spidev_out).with([0, 1, 2, 3, 4, 5])
      Rpio::SPI.spidev_out([0, 1, 2, 3, 4, 5])
    end
  end
end
