# encoding: UTF-8

require 'rubygems'
require 'sprockets'
require 'net/http'
require 'rack'
require 'yaml'
require 'selenium/webdriver'
require File.join(File.dirname(__FILE__), 'seaweed', 'version')

module Seaweed
  ROOT            = File.expand_path File.join(File.dirname(__FILE__), '..')
  PROJECT_ROOT    = File.expand_path "."
  
  CONFIG_PATHS    = [
    File.join(PROJECT_ROOT, 'seaweed.yml'),
    File.join(PROJECT_ROOT, 'config', 'seaweed.yml')
  ]
  
  @configuration  = {}
  
  def self.load_configuration
    # Set configuration defaults
    @configuration['port']  = 4567
    @configuration['libs']  = ['lib']
    @configuration['specs'] = ['spec']
    
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

  def self.port= value
    @configuration['port'] = value
  end
  
  def self.root_url
    "http://localhost:#{port}/"
  end
  
  def self.libs
    @configuration['libs']
  end
  
  def self.specs
    @configuration['specs']
  end
  
  def self.all_paths
    libs + specs
  end

  def self.server
    trap_sigint
    spawn_server
    Thread.stop
  end

  def self.cli
    trap_sigint
    spawn_server
    result = Seaweed.run_suite
    shut_down(result ? 0 : 1) 
  end

  def self.autotest
    trap_sigint
    spawn_server
    run_suite
    watch_for_changes
    Thread.stop
  end
  
  # Prepares a Sprockets::Environment object to serve coffeescript assets
  def self.sprockets_environment
    @environment ||= Sprockets::Environment.new.tap do |environment|
      environment.append_path File.join(Seaweed::ROOT, 'lib')
      all_paths.each do |path|
        environment.append_path path
      end
    end
  end
  
  def self.start_server
    app = Rack::Builder.app do
      map '/assets' do
        run Seaweed.sprockets_environment
      end
      
      map '/' do
        run Seaweed::Server
      end
    end
    Rack::Handler.default.run app, :Port => port
  end
  
  def self.spawn_server
    # Start server in its own thread
    @server = Thread.new &method(:start_server)
    
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
      @browser.navigate.refresh
    else
      @browser = Selenium::WebDriver.for :firefox, profile: Selenium::WebDriver::Firefox::Profile.new
      @browser.get "#{root_url}#terminal"
    end
    result = @browser[css: '.results'].text
    puts result
    !!result.match('passed, 0 failed')
  end

  def self.watch_for_changes
    require 'listen'
    
    @listener = Listen.to(PROJECT_ROOT)

    # Match .coffee files in any project paths
    @listener.filter Regexp.new('^(' + all_paths.map{ |s| Regexp.escape s}.join('|') + ')\/.*\.coffee$')

    @listener.change { run_suite }
    @listener.start false
  end

  def self.shut_down(status=0)
    @listener.stop if @listener
    @browser.close if @browser
    @server.exit   if @server
    exit status
  end

  def self.trap_sigint
    trap('SIGINT') do
      puts "Shutting down..."
      shut_down
    end
  end
end

require File.expand_path(File.dirname(__FILE__) + '/seaweed/server')
