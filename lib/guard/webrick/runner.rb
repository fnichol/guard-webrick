require 'webrick'

module Guard
  class WEBrick
    class Runner

      attr_reader :pid
      
      def initialize(options)
        @options = options
      end

      def start
        if pid
          UI.error "An instance of WEBrick::HTTPServer is already running."
        else
          fork_child_pid
        end
      end

      def stop
        Process.kill("HUP", pid)
        @pid = nil
        true
      end

      def restart
        stop
        start
      end

    private

      def fork_child_pid
        @pid = Process.fork do
          server = ::WEBrick::HTTPServer.new(
            :BindAddress  => @options[:host],
            :Port         => @options[:port],
            :DocumentRoot => Dir::pwd
          )
          %w{INT HUP}.each { |sig| Signal.trap(sig){ server.shutdown } }
          server.start
        end
      end
    end
  end
end
