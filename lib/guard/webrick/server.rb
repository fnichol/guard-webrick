require 'webrick'
require 'webrick/https'

module Guard
  class WEBrick
    class Server

      attr_reader :server

      def initialize(options = {})
        if options[:ssl]
          @server = ::WEBrick::HTTPServer.new(
            :BindAddress  => options[:host],
            :Port         => options[:port],
            :DocumentRoot => File.expand_path(options[:docroot]),
            :SSLEnable    => true,
            :SSLCertName  => [%w[CN localhost]]
          )
        else
          @server = ::WEBrick::HTTPServer.new(
            :BindAddress  => options[:host],
            :Port         => options[:port],
            :DocumentRoot => File.expand_path(options[:docroot])
          )
        end
      end

      def start
        %w{TERM HUP}.each { |signal| trap(signal){ server.shutdown } }
        # ignore signals for guard
        %w{INT TSTP QUIT}.each { |signal| trap(signal) {} }
        @server.start
      end
    end
  end
end

if __FILE__ == $0
  host, port, ssl, docroot = ARGV
  Guard::WEBrick::Server.new(
    :host     => host,
    :port     => port,
    :ssl      => ssl == 'true',
    :docroot  => docroot
  ).start
end
