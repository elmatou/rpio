RSpec.describe Rpio::Gpio do

  before(:context) do
    Rpio.driver = Rpio::StubDriver::Base
  end

  xit '#watch(options, &block)'
  xit '#after(options, &block)'

  context 'when instantiate' do
    it 'should set pin for input' do
      expect(Rpio.driver).to receive(:pin_direction).with(4, :in)
      Rpio::Gpio.new pin: 4, direction: :in
    end

    it 'should set pin for output' do
      expect(Rpio.driver).to receive(:pin_direction).with(4, :out)
      Rpio::Gpio.new pin: 4, direction: :out
    end

    it 'should read start value on construction' do
      expect(Rpio.driver).to receive(:pin_read).with(4).and_return(0)
      Rpio::Gpio.new pin: 4, direction: :in
    end

    it 'should accept pulls when direction is :in' do
      expect(Rpio.driver).to receive(:pin_set_pud).with(17, :up)
      expect(Rpio.driver).to receive(:pin_set_pud).with(18, :down)
      expect(Rpio.driver).to receive(:pin_set_pud).with(19, :off)
      expect(Rpio.driver).to receive(:pin_set_pud).with(20, :float)

      Rpio::Gpio.new(pin: 17, direction: :in, pull: :up)
      Rpio::Gpio.new(pin: 18, direction: :in, pull: :down)
      Rpio::Gpio.new(pin: 19, direction: :in, pull: :off)
      Rpio::Gpio.new(pin: 20, direction: :in, pull: :float)
    end

    it 'should not accept pulls when direction is :out' do
      expect{ Rpio::Gpio.new(pin: 17, direction: :out, pull: :up) }.to raise_error ArgumentError
      expect{ Rpio::Gpio.new(pin: 17, direction: :out, pull: :down) }.to raise_error ArgumentError
      expect{ Rpio::Gpio.new(pin: 17, direction: :out, pull: :off) }.not_to raise_error
    end

    it 'should accept trigger' do
      expect(Rpio.driver).to receive(:pin_set_trigger).with(17, :any_trigger)
      expect(Rpio.driver).to receive(:pin_set_trigger).with(18, :none)
      Rpio::Gpio.new(pin: 17, direction: :in, trigger: :any_trigger)
      Rpio::Gpio.new(pin: 18, direction: :in)
    end
  end


  context 'when direction is in' do
    subject { Rpio::Gpio.new pin: 4, direction: :in }

    it 'should detect on?' do
      expect(Rpio.driver).to receive(:pin_read).with(4).and_return(1)
      expect(subject.on?).to be(true)
    end

    it 'should detect off?' do
      expect(Rpio.driver).to receive(:pin_read).with(4).and_return(0)
      expect(subject.off?).to be(true)
    end

    it 'should not write high on direction in' do
      expect(Rpio.driver).not_to receive(:pin_write)
      subject.on
    end

    it 'should not write low on direction in' do
      expect(Rpio.driver).not_to receive(:pin_write)
      subject.off
    end

    it 'should detect high to low change' do
      value = 1
      allow(Rpio.driver).to receive(:pin_read) { value ^= 1 } # begins low, then high, low, high, low...

      expect(subject.off?).to be(true)
      subject.read
      expect(subject.off?).to be(false)
      expect(subject.changed?).to be(true)
    end

    context 'when invert is true' do
      subject { Rpio::Gpio.new pin: 4, direction: :in, invert: true }

      it 'should invert true' do
        expect(Rpio.driver).to receive(:pin_read).with(4).and_return(1)
        expect(subject.on?).to be(false)
      end

      it 'should invert true' do
        expect(Rpio.driver).to receive(:pin_read).with(4).and_return(0)
        expect(subject.off?).to be(false)
      end
    end
  end

  context 'when direction is out' do
    subject { Rpio::Gpio.new pin: 4, direction: :out }

    it 'should write high' do
      expect(Rpio.driver).to receive(:pin_write).with(4, 1)
      subject.on
    end

    it 'should write low' do
      expect(Rpio.driver).to receive(:pin_write).with(4, 0)
      subject.off
    end
  end

  context 'when direction is out' do
    subject { Rpio::Gpio.new pin: 4, direction: :in, trigger: :rising }

    it 'should wait for change' do
      expect(Rpio.driver).to receive(:pin_wait_for).with(4)
      subject.wait_for_change
    end

    it 'should send to the driver any unkown methods' do
      expect(Rpio.driver).to receive(:unknown_method).with(4, 'any_argument')
      subject.unknown_method('any_argument')
    end
  end
end
