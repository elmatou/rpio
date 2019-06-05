RSpec.describe Rpio do
  it "has a version number" do
    expect(Rpio::VERSION).not_to be nil
  end

  it 'should get the default driver' do
    expect(Rpio.driver).to be_an_instance_of Rpio::StubDriver::Base
  end

  it 'should set a driver' do
    Rpio.driver= Rpio::StubDriver::Base
    expect{ Rpio.driver= Numeric }.to raise_error ArgumentError
    expect{ Rpio.driver= nil }.to raise_error ArgumentError
    expect{ Rpio.driver= Rpio::StubDriver::Base }.not_to raise_error
  end

  it 'should take in Rpio::StubDriver::Base subclasses' do
    expect( Rpio.driver ).to receive(:close)
    expect{ Rpio.driver= Rpio::StubDriver::Base }.not_to raise_error
    expect{ Rpio.driver= Rpio::StubDriver }.to raise_error ArgumentError, 'Supply a Rpio::Driver::Base subclass for driver'
  end

  xit 'should close the loaded driver at_exit'
  xit '#wait'
end
