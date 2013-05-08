# encoding: UTF-8

require 'rubygems'
require 'sprockets'
require 'net/http'
require 'rack'
require 'json'
require File.join(File.dirname(__FILE__), 'gusto', 'version')

module Gusto
  ROOT            = File.expand_path File.join(File.dirname(__FILE__), '..')
  PROJECT_ROOT    = File.expand_path "."

  CONFIG_PATHS    = [
    File.join(PROJECT_ROOT, 'gusto.json'),
    File.join(PROJECT_ROOT, 'config', 'gusto.json')
  ]

  @configuration  = {}

  class << self

    def load_configuration
      # Set configuration defaults
      @configuration['port']  = 4567
      @configuration['lib_paths']   = %w(lib)
      @configuration['spec_paths']  = %w(spec)

      # Load custom configuration file
      CONFIG_PATHS.each do |path|
        if File.exists? path
          @configuration.merge! JSON.parse(File.read(path))
          puts "Loaded configuration from “#{path}”"
        end
      end
    end

    def port
      @configuration['port']
    end

    def port= value
      @configuration['port'] = value
    end

    def root_url
      "http://localhost:#{port}/"
    end

    def libs
      @configuration['lib_paths']
    end

    def specs
      @configuration['spec_paths']
    end

    def all_paths
      libs + specs
    end

    def server
      trap_sigint
      spawn_server
      Process.waitall
    end

    def cli
      trap_sigint
      spawn_server
      result = run_suite
      shut_down(result ? 0 : 1)
    end

    def autotest
      trap_sigint
      spawn_server
      run_suite
      watch_for_changes
      Process.waitall
    end

    # Prepares a Sprockets::Environment object to serve coffeescript assets
    def sprockets_environment
      @environment ||= Sprockets::Environment.new.tap do |environment|
        environment.append_path File.join(ROOT, 'lib')
        environment.append_path File.join(ROOT, 'assets')
        all_paths.each do |path|
          environment.append_path path
        end
      end
    end

    def start_server
      app = Rack::Builder.app do
        map '/assets' do
          run Gusto::sprockets_environment
        end

        map '/' do
          run Gusto::Server
        end
      end
      Rack::Handler.default.run app, :Port => port
    end

    def spawn_server
      @server = Process.fork{ $0 = 'gusto server'; start_server }
      wait_for_server_at(root_url)
    end

    def run_suite
      if @browser
        @browser.navigate.refresh
      else
        require 'selenium/webdriver'
        @browser = Selenium::WebDriver.for :firefox, profile: Selenium::WebDriver::Firefox::Profile.new
        @browser.get "#{root_url}#terminal"
      end
      result = @browser[css: '.results'].text
      puts result
      !!result.match('passed, 0 failed')
    end

    def watch_for_changes
      require 'listen'

      @listener = Listen.to(PROJECT_ROOT)

      # Match .coffee files in any project paths
      @listener.filter Regexp.new('^(' + all_paths.map{ |s| Regexp.escape s}.join('|') + ')\/.*\.coffee$')

      @listener.change { run_suite }
      @listener.start false
    end

    def shut_down(status=0)
      @listener.stop if @listener
      @browser.close if @browser
      Process.kill 'TERM', @server if @server
      exit status
    end

    def trap_sigint
      trap('SIGINT') do
        puts "Shutting down..."
        shut_down
      end
    end

    private

    def wait_for_server_at(url)
      page = Net::HTTP.get URI.parse(url)
    rescue Errno::ECONNREFUSED
      sleep 1
      retry
    end
  end
end

require File.expand_path(File.dirname(__FILE__) + '/gusto/server')
