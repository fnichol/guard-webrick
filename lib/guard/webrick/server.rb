require 'webrick'

module Guard
  class WEBrick
    class Server

      attr_reader :server

      def initialize(options = {})
        @server = ::WEBrick::HTTPServer.new(
          :BindAddress  => options[:host],
          :Port         => options[:port],
          :DocumentRoot => options[:docroot]
        )
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
  host, port, docroot = ARGV
  Guard::WEBrick::Server.new(
    :host     => host,
    :port     => port,
    :docroot  => docroot
  ).start
end
