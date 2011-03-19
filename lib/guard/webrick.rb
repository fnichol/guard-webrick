require 'guard'
require 'guard/guard'
require 'spoon'
require 'launchy'

module Guard
  class WEBrick < Guard

    attr_accessor :pid

    def initialize(watchers=[], options={})
      super
      @options = {
        :host       => '0.0.0.0',
        :port       => 3000,
        :launchy    => true
      }.update(options)
    end

    # =================
    # = Guard methods =
    # =================

    # Call once when guard starts
    def start
      UI.info "Starting up WEBrick..."
      if running?
        UI.error "Another instance of WEBrick::HTTPServer is running."
        false
      else
        @pid = Spoon.spawnp('ruby',
          File.expand_path(File.join(File.dirname(__FILE__), %w{webrick server.rb})),
          @options[:host],
          @options[:port].to_s,
          Dir::pwd
        )
        Launchy.open("http://#{@options[:host]}:#{@options[:port]}")
        @pid
      end
    end

    # Call with Ctrl-C signal (when Guard quit)
    def stop
      UI.info "Shutting down WEBrick..."
      Process.kill("TERM", @pid)
      Process.wait(@pid)
      @pid = nil
      true
    end

    # Call with Ctrl-Z signal
    def reload
      restart
    end

    # Call on file(s) modifications
    def run_on_change(paths = {})
      restart
    end

    private

    def restart
      UI.info "Restarting WEBrick..."
      stop
      start
    end

    def running?
      begin
        if @pid
          Process.getpgid @pid
          true
        else
          false
        end
      rescue Errno::ESRCH
        false
      end
    end
  end
end
