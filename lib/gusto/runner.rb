# encoding: UTF-8

module Gusto
  class Runner
    def load_gusto
      require File.join(File.dirname(__FILE__), '..', 'gusto')
      Gusto.verbose = @verbose
      Gusto::Configuration.load
      Gusto::Configuration.port = @port
    end

    def load_gusto_version
      require File.join(File.dirname(__FILE__), '..', 'gusto', 'version')
    end

    def initialize(mode, options={}, parser=nil)
      @port = options[:port] || 4567
      @verbose = options[:verbose]

      if options[:version]
        load_gusto_version
        puts "Gusto Version #{Gusto::VERSION}"
      else
        case mode
          when 's', 'server'
            load_gusto
            Gusto.server
          when 'c', 'cli'
            load_gusto
            Gusto.cli
          when 'a', 'auto'
            load_gusto
            Gusto.autotest
          else
            puts parser || "Unknown mode “#{mode}”"
        end
      end
    end
  end
end
