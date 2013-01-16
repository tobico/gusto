# encoding: UTF-8

require File.expand_path(File.dirname(__FILE__) + '/../seaweed')

module Seaweed
  class Runner
    def initialize mode, options={}, parser=nil
      Seaweed.load_configuration
      
      Seaweed.port = options[:port] if options[:port]
      
      if options[:version]
        puts "Seaweed Version #{Seaweed::VERSION}"
      else      
        case mode
          when 's', 'server'
            Seaweed.start_server
          when 'c', 'ci'
            Seaweed.spawn_server
            result = Seaweed.run_suite
            Seaweed.close_browser
            exit 1 unless result
          when 'a', 'auto'
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
