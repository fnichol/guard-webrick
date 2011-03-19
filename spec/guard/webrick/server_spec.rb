require 'spec_helper'
require 'guard/webrick/server'

describe Guard::WEBrick::Server do

  describe "initialize" do

    it "should create a WEBrick::HTTPServer instance" do
      ::WEBrick::HTTPServer.should_receive(:new).with(
        :BindAddress  => '0.0.0.0',
        :Port         => 3000,
        :DocumentRoot => Dir::pwd
      )
      new_server
    end

    it "should expand the docroot path" do
      ::WEBrick::HTTPServer.should_receive(:new).with(
        :BindAddress  => '0.0.0.0',
        :Port         => 3000,
        :DocumentRoot => File.expand_path(File.join(Dir::pwd, 'public'))
      )
      new_server(:docroot => 'public')
    end
  end

  describe "start" do

    subject { new_server }

    it "should start the WEBrick::HTTPServer instance" do
      ::WEBrick::HTTPServer.stub(:new).and_return(mock_http_server)
      subject.server.should_receive(:start)
      subject.start
    end
  end
end

def new_server(options = {})
  Guard::WEBrick::Server.new({
    :host     => '0.0.0.0',
    :port     => 3000,
    :docroot  => Dir::pwd
  }.update(options))
end

def mock_http_server
  @mock_http_server ||= mock(::WEBrick::HTTPServer).as_null_object
end
