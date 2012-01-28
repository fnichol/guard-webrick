require 'spec_helper'

describe Guard::WEBrick do
  subject { Guard::WEBrick.new }

  before(:each) do
    Launchy.stub(:open)
  end

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

    describe "ssl" do

      it "should be false by default" do
        subject = Guard::WEBrick.new([])
        subject.options[:ssl].should be_false
      end

      it "should be set to true" do
        subject = Guard::WEBrick.new([], { :ssl => true })
        subject.options[:ssl].should be_true
      end
    end

    describe "docroot" do

      it "should be Dir::pwd by default" do
        subject = Guard::WEBrick.new([])
        subject.options[:docroot].should == Dir::pwd
      end

      it "should be set to #{File.join(Dir::pwd, 'public')}" do
        subject = Guard::WEBrick.new([], { :docroot => File.join(Dir::pwd, 'public') })
        subject.options[:docroot].should == File.join(Dir::pwd, 'public')
      end
    end

    describe "launchy" do

      it "should be true by default" do
        subject = Guard::WEBrick.new([])
        subject.options[:launchy].should == true
      end

      it "should be set to false" do
        subject = Guard::WEBrick.new([], { :launchy => false })
        subject.options[:launchy].should == false
      end
    end
  end

  describe "start" do

    before(:each) do
      Spoon.stub(:spawnp).and_return(123456)
      subject.stub(:wait_for_port)
    end

    it "should spawn the server instance" do
      subject = Guard::WEBrick.new([], {
        :host => '127.0.2.5',
        :port => 8080,
        :ssl => true,
        :docroot => '/tmp' })
      subject.stub(:wait_for_port)
      Spoon.should_receive(:spawnp).with( 'ruby',
        File.expand_path(File.join(File.dirname(__FILE__),
          %w{.. .. lib guard webrick server.rb})),
        '127.0.2.5', '8080', 'true', '/tmp'
      )
      subject.start
    end

    it "should pass startup options to the server instance" do
      Spoon.should_receive(:spawnp).with( 'ruby',
        File.expand_path(File.join(File.dirname(__FILE__),
          %w{.. .. lib guard webrick server.rb})),
        '0.0.0.0', '3000', 'false', Dir::pwd
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

    it "should warn when server instance is already running" do
      subject.start
      Process.stub(:getpgid).and_return(true)
      Guard::UI.should_receive(:error).with(
        "Another instance of WEBrick::HTTPServer is running.")
      subject.start
    end

    it "should open a web browser page" do
      Launchy.should_receive(:open).with("http://0.0.0.0:3000")
      subject.start
    end

    it "should not open a web browser if disabled" do
      subject = Guard::WEBrick.new([], { :launchy => false })
      subject.stub(:wait_for_port)
      Launchy.should_not_receive(:open)
      subject.start
    end
  end

  describe "stop" do

    before(:each) do
      Spoon.stub(:spawnp).and_return(123456)
      Process.stub(:wait)
      Process.stub(:kill)
      subject.stub(:wait_for_port)
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
        subject.stub(:wait_for_port)
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

      it "should only open a web browser the first time" do
        subject = Guard::WEBrick.new([], { :launchy => true })
        subject.stub(:wait_for_port)
        Launchy.should_receive(:open).once
        subject.start
        subject.send(method)
      end
    end
  end
end
