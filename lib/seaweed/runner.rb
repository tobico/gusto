# encoding: UTF-8

require File.expand_path(File.dirname(__FILE__) + '/../seaweed')

module Seaweed
  class Runner
    def initialize mode='auto'
      Seaweed.load_configuration
      
      case mode
        when 's', 'server'
          Seaweed.start_server
        when nil, 't', 'terminal'
          Seaweed.spawn_server
          Seaweed.run_suite
        when 'a', 'auto'
          Seaweed.spawn_server
          Seaweed.run_suite
          Seaweed.watch_for_changes
        else
          puts "Unknown mode “#{mode}”"
      end
    end
  end
end