RSpec.describe Rpio do

  before(:context) do
    Rpio.driver = Rpio::StubDriver::Base
  end

  it "has a version number" do
    expect(Rpio::VERSION).not_to be nil
  end

  it 'should get the default driver' do
    expect(Rpio.driver).to be_a_kind_of Rpio::Driver
  end

  it 'should set a driver' do
    Rpio.driver= Rpio::Driver
    expect{ Rpio.driver= Numeric }.to raise_error ArgumentError
    expect{ Rpio.driver= nil }.to raise_error ArgumentError
    expect{ Rpio.driver= Rpio::Driver }.not_to raise_error
  end

  it 'should take in Rpio::Driver subclasses' do
    expect( Rpio.driver ).to receive(:close)
    expect{ Rpio.driver= Rpio::Driver }.not_to raise_error
    expect{ Rpio.driver= Rpio::StubDriver }.to raise_error ArgumentError, 'Supply a Rpio::Driver subclass for driver'
  end

  xit 'should close the loaded driver at_exit'
  xit '#wait'
end
