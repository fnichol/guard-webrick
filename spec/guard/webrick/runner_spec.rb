require 'spec_helper'

describe Guard::WEBrick::Runner do

  before(:each) do
    ::WEBrick::HTTPServer.stub(:new).and_return(mock_server)
  end

  describe "start" do

    subject { new_runner }

    it "should fork a new process for the HTTPServer" do
      Process.stub(:fork).and_return(12345)
      subject.start
      subject.pid.should == 12345
    end

    it "should create a WEBrick::HTTPServer instance" do
      Process.stub(:fork) do |block|
        ::WEBrick::HTTPServer.should_receive(:new).with(
          :BindAddress  => '0.0.0.0',
          :Port         => 3000,
          :DocumentRoot => Dir::pwd
        )
        block.call
      end
      subject.start
    end

    it "should start a WEBrick::HTTPServer instance" do
      Process.stub(:fork) do |block|
        mock_server.should_receive(:start)
        block.call
      end
      subject.start
    end

    it "should display an error message if server is running" do
      Process.stub(:fork).and_return(12345)
      subject.start
      Guard::UI.should_receive(:error).with("An instance of WEBrick::HTTPServer is already running.")
      subject.start
    end
  end

  describe "stop" do

    subject { new_runner }

    it "should kill the process running the HTTPServer" do
      Process.stub(:fork).and_return(12345)
      Process.should_receive(:kill).with("HUP", 12345)
      subject.start
      subject.stop
    end

    it "should set the pid back to nil" do
      Process.stub(:fork).and_return(12345)
      Process.should_receive(:kill).with("HUP", 12345)
      subject.start
      subject.stop
      subject.pid.should be_nil
    end

    it "should shutdown the WEBrick::HTTPServer instance" do
      make_fake_forked_server
      Signal.trap("USR1") { @css = true }

      subject.start
      sleep 0.05    # wait for HTTPServer to fork and start
      subject.stop
      sleep 0.05    # wait to get USR1 signal from child pid
      @css.should be_true
    end
  end

  describe "restart" do

    it "should call stop then start" do
      subject = new_runner
      subject.start
      subject.should_receive(:stop).ordered
      subject.should_receive(:start).ordered
      subject.restart
    end
  end
end

def new_runner(options = {})
  Guard::WEBrick::Runner.new({:host => '0.0.0.0', :port => 3000,
    :launch_url => true})
end

def mock_server
  @mock_server ||= mock(::WEBrick::HTTPServer).as_null_object
end

def make_fake_forked_server
  @shutdown_called = false

  # wait until shutown was called, simulating blocking pid
  mock_server.stub(:start) do
    until @shutdown_called do ; sleep 0.01 ; end
  end

  # trigger #start to end and signal parent process (rspec test) so we
  # know #shutdown was called
  mock_server.stub(:shutdown) do
    @shutdown_called = true
    Process.kill("USR1", Process.ppid)
  end
end
