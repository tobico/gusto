require 'rubygems'
require 'celerity'
require 'net/http'
require 'rack'
require 'yaml'

module Seaweed
  VERSION         = "0.1.2"
  ROOT            = File.expand_path File.join(File.dirname(__FILE__), '..')
  PROJECT_ROOT    = File.expand_path "."
  
  CONFIG_PATHS    = [
    File.join(PROJECT_ROOT, 'seaweed.yml'),
    File.join(PROJECT_ROOT, 'config', 'seaweed.yml')
  ]
  
  @configuration  = {}
  
  def self.load_configuration
    # Set configuration defaults
    @configuration['port']        = 4567
    @configuration['lib_dirs']    = ['lib']
    @configuration['spec_dirs']   = ['spec']
    @configuration['js_libs']     = []
    
    # Load custom configuration file
    CONFIG_PATHS.each do |path|
      if File.exists? path
        @configuration.merge! YAML.load(File.read(path))
        puts "Loaded configuration from “#{path}”"
      end
    end
  end

  def self.port
    @configuration['port']
  end
  
  def self.root_url
    "http://localhost:#{port}/"
  end
  
  def self.lib_paths
    @configuration['lib_dirs']
  end
  
  def self.spec_paths
    @configuration['spec_dirs']
  end
  
  def self.all_paths
    lib_paths + spec_paths
  end
  
  def self.js_libs
    @configuration['js_libs']
  end
  
  def self.start_server
    app = Rack::Builder.app { run Seaweed::Server }
    Rack::Handler.default.run app, :Port => port
  end
  
  def self.spawn_server
    # Start server in its own thread
    Thread.new &start_server
    
    # Keep trying to connect to server until we succeed
    begin
      page = Net::HTTP.get URI.parse(root_url)
    rescue Errno::ECONNREFUSED
      sleep 1
      retry
    end
  end
  
  def self.run_suite
    if @browser
      @browser.refresh
    else
      @browser = Celerity::Browser.new
      @browser.goto "#{root_url}#terminal"
    end
    puts @browser.text
  end
  
  def self.watch_for_changes
    require 'watchr'
    
    # Build a regexp to match .coffee files in any project paths
    path_matcher = Regexp.new('^(' + all_paths.map{ |s| Regexp.escape s}.join('|') + ')\/.*\.coffee$')
    
    script = Watchr::Script.new
    script.watch(path_matcher) { run_suite }
    controller = Watchr::Controller.new(script, Watchr.handler.new)
    controller.run
  end
end

require File.expand_path(File.dirname(__FILE__) + '/seaweed/server')