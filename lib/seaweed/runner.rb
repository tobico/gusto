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
            load_seaweed
            Seaweed.start_server
          when 'c', 'ci'
            load_seaweed
            Seaweed.spawn_server
            result = Seaweed.run_suite
            Seaweed.close_browser
            exit 1 unless result
          when 'a', 'auto'
            load_seaweed
            Seaweed.spawn_server
            Seaweed.run_suite
            Seaweed.watch_for_changes
          else
            puts parser || "Unknown mode “#{mode}”"
        end
      end
    end
  end
end
