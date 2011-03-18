require 'webrick'

module Guard
  class WEBrick
    class Runner

      attr_reader :pid
      
      def initialize(options)
        @pid = Process.fork do
          server = ::WEBrick::HTTPServer.new(
            :BindAddress  => options[:host],
            :Port         => options[:port]
          )
          %w{INT HUP}.each do |sig|
            Signal.trap(sig){ server.shutdown }
          end
          server.start
        end
      end

      def stop
        Process.kill("HUP", pid)
      end
    end
  end
end
