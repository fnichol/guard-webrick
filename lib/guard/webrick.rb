require 'guard'
require 'guard/guard'

module Guard
  class WEBrick < Guard

    autoload :Runner, 'guard/webrick/runner'

    attr_accessor :runner

    def initialize(watchers=[], options={})
      super
      @options = {
        :host       => '0.0.0.0',
        :port       => 3000,
        :launch_url => true
      }.update(options)
      @runner = Runner.new(@options)
    end

    # =================
    # = Guard methods =
    # =================

    # Call once when guard starts
    def start
      UI.info "Starting up WEBrick..."
      runner.start
    end

    # Call with Ctrl-C signal (when Guard quit)
    def stop
      UI.info "Shutting down WEBrick..."
      runner.stop
    end

    # Call with Ctrl-Z signal
    def reload
      UI.info "Restarting WEBrick..."
      runner.restart
    end

    # Call on file(s) modifications
    def run_on_change(paths = {})
      UI.info "Restarting WEBrick..."
      runner.restart
    end
  end
end
