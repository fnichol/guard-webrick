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

  describe "start" do

    before(:each) do
      Spoon.stub(:spawnp).and_return(123456)
    end

    it "should spawn the server instance" do
      Spoon.should_receive(:spawnp).with( 'ruby',
        File.expand_path(File.join(File.dirname(__FILE__),
          %w{.. .. lib guard webrick server.rb})),
        '0.0.0.0', '3000', Dir::pwd
      )
      subject.start
    end

    it "should set the pid" do
      subject.start
      subject.pid.should == 123456
    end

    it "should return true" do
      subject.start.should be_true
    end
  end

  describe "stop" do

    before(:each) do
      Spoon.stub(:spawnp).and_return(123456)
      Process.stub(:wait)
      Process.stub(:kill)
      subject.start
    end

    it "should kill the server instance" do
      Process.should_receive(:kill).with("TERM", 123456)
      subject.stop
    end

    it "should wait for the child process to exit" do
      Process.should_receive(:wait).with(123456)
      subject.stop
    end

    it "should set pid to nil" do
      subject.stop
      subject.pid.should be_nil
    end

    it "should return true" do
      subject.stop.should be_true
    end
  end

  %w{reload run_on_change}.each do |method|
    describe method do

      before(:each) do
        Spoon.stub(:spawnp).and_return(123456)
        Process.stub(:wait)
        Process.stub(:kill)
        subject.start
      end

      it "should restart the server" do
        subject.should_receive(:stop).ordered
        subject.should_receive(:start).ordered
        subject.send(method)
      end

      it "should return true" do
        subject.send(method).should be_true
      end
    end
  end
end
