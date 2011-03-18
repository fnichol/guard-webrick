require 'spec_helper'

describe Guard::WEBrick do
  subject { Guard::WEBrick.new }

  describe "options" do

    describe "host" do

      it "should be '0.0.0.0' by default" do
        subject = Guard::WEBrick.new([])
        subject.options[:host].should == '0.0.0.0'
      end

      it "should be set to '127.0.0.5'" do
        subject = Guard::WEBrick.new([], { :host => '127.0.0.5' })
        subject.options[:host].should == '127.0.0.5'
      end
    end

    describe "port" do

      it "should be 3000 by default" do
        subject = Guard::WEBrick.new([])
        subject.options[:port].should == 3000
      end

      it "should be set to 8080" do
        subject = Guard::WEBrick.new([], { :port => 8080 })
        subject.options[:port].should == 8080
      end
    end

    describe "launch_url" do

      it "should be true by default" do
        subject = Guard::WEBrick.new([])
        subject.options[:launch_url].should == true
      end

      it "should be set to false" do
        subject = Guard::WEBrick.new([], { :launch_url => false })
        subject.options[:launch_url].should == false
      end
    end
  end

  describe "initialize" do

    it "should create a server instance with default options" do
      Guard::WEBrick::Runner.should_receive(:new).with(
        :host       => '0.0.0.0',
        :port       => 3000,
        :launch_url => true
      )
      Guard::WEBrick.new([])
    end
  end

  describe "start" do
    it "should start the server instance" do
      runner = mock(Guard::WEBrick::Runner)
      subject.stub(:runner).and_return(runner)
      runner.should_receive(:start)
      subject.start
    end
  end

  describe "stop" do

    it "should stop the running server instance" do
      runner = mock(Guard::WEBrick::Runner)
      subject.stub(:runner).and_return(runner)
      runner.should_receive(:stop)
      subject.stop
    end
  end

  %w{reload run_on_change}.each do |method|
    describe method do
      it "should restart the server instance" do
        runner = mock(Guard::WEBrick::Runner)
        subject.stub(:runner).and_return(runner)
        runner.should_receive(:restart)
        subject.send(method)
      end
    end
  end
end
