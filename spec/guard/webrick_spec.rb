require 'spec_helper'

describe Guard::WEBrick do
  subject { Guard::WEBrick.new }

  describe "start" do
    it "should start a server instance with default options" do
      subject = Guard::WEBrick.new([])
      Guard::WEBrick::Runner.should_receive(:new).with(
        :host       => '0.0.0.0',
        :port       => '3000',
        :launch_url => true
      )
      subject.start
    end
  end

  describe "stop" do
    it "should stop the server instance"
  end

  describe "run_on_change" do
    it "should restart the server instance"
  end
end
