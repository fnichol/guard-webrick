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
      runner.start
    end

    # Call with Ctrl-C signal (when Guard quit)
    def stop
      runner.stop
    end

    # Call with Ctrl-Z signal
    def reload
      runner.restart
    end

    # Call on file(s) modifications
    def run_on_change(paths = {})
      runner.restart
    end
  end
end
