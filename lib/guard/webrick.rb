require 'guard'
require 'guard/guard'

module Guard
  class WEBrick < Guard

    autoload :Runner, 'guard/webrick/runner'

    def initialize(watchers=[], options={})
      super
      # init stuff here
    end

    # =================
    # = Guard methods =
    # =================

    def start
      Runner.new(
        :host       => '0.0.0.0',
        :port       => '3000',
        :launch_url => true
      )
      true
    end

    def stop
      true
    end

    def run_on_change(paths)
      true
    end
  end
end
