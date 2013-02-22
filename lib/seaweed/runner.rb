# encoding: UTF-8


module Seaweed
  class Runner
    def load_seaweed
      require File.join(File.dirname(__FILE__), '..', 'seaweed')
      Seaweed.load_configuration
      Seaweed.port = @port
    end

    def load_seaweed_version
      require File.join(File.dirname(__FILE__), '..', 'seaweed', 'version')
    end

    def initialize mode, options={}, parser=nil
      @port = options[:port] || 4567
      
      if options[:version]
        load_seaweed_version
        puts "Seaweed Version #{Seaweed::VERSION}"
      else
        case mode
          when 's', 'server'
            puts "Starting seaweed server at http://127.0.0.1:#{@port}/"
            load_seaweed
            Seaweed.server
          when 'c', 'cli'
            load_seaweed
            Seaweed.cli
          when 'a', 'auto'
            load_seaweed
            Seaweed.autotest
          else
            puts parser || "Unknown mode “#{mode}”"
        end
      end
    end
  end
end
