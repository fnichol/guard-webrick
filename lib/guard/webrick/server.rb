require 'webrick'
require 'webrick/https'

module Guard
  class WEBrick
    class Server

      attr_reader :server

      def initialize(options = {})
        config = {
          :BindAddress  => options[:host],
          :Port         => options[:port],
          :DocumentRoot => File.expand_path(options[:docroot])
        }

        if options[:suppress_log]
          config.merge!({
            :Logger       => ::WEBrick::Log.new("/dev/null"),
            :AccessLog    => []
          })
        end

        if options[:ssl]
          config.merge!({
            :SSLEnable    => true,
            :SSLCertName  => [%w[CN localhost]],
          })
        end

        @server = ::WEBrick::HTTPServer.new(config)
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
  host, port, ssl, docroot, suppress_log = ARGV
  Guard::WEBrick::Server.new(
    :host         => host,
    :port         => port,
    :ssl          => ssl == 'true',
    :docroot      => docroot,
    :suppress_log => suppress_log == 'true'
  ).start
end
