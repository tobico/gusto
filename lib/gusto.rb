# encoding: UTF-8

require 'rubygems'
require 'sprockets'
require 'net/http'
require 'rack'
require 'json'
require 'logger'
require File.join(File.dirname(__FILE__), 'gusto', 'version')

module Gusto
  autoload :Configuration,  File.join(File.dirname(__FILE__), 'gusto', 'configuration')
  autoload :Server,         File.join(File.dirname(__FILE__), 'gusto', 'server')
  autoload :ServerSpawner,  File.join(File.dirname(__FILE__), 'gusto', 'server_spawner')
  autoload :Sprockets,      File.join(File.dirname(__FILE__), 'gusto', 'sprockets')
  autoload :CliRenderer,    File.join(File.dirname(__FILE__), 'gusto', 'cli_renderer')

  HEADLESS_RUNNER_PATH =    File.realpath(
    File.join(File.dirname(__FILE__), '..', 'phantom', 'headless_runner.js'))

  class << self
    attr_accessor :verbose

    def logger
      @logger ||= Logger.new(STDOUT).tap do |logger|
        logger.level = verbose ? Logger::DEBUG : Logger::INFO
      end
    end

    def root
      File.expand_path File.join(File.dirname(__FILE__), '..')
    end

    def project_root
      File.expand_path "."
    end

    def server
      trap_sigint
      server_spawner.spawn
      Process.waitall
    end

    def cli
      server_spawner.spawn
      result = run_suite?(server_spawner.port)
    ensure
      shut_down(result ? 0 : 1)
    end

    def autotest
      trap_sigint
      sever_spawner.spawn
      run_suite?(server_spawner.port)
      watch_for_changes
      Process.waitall
    end

    def run_suite?(port)
      Gusto.logger.debug{ "Running test suite with phantomjs" }
      json = `phantomjs #{Shellwords.escape HEADLESS_RUNNER_PATH} #{port}`

      Gusto.logger.debug{ "Parsing JSON response" }
      report = JSON.parse json

      Gusto.logger.debug{ "Rendering test results" }
      puts CliRenderer.new(report).render

      report['status'] != 2
    rescue => e
      Gusto.logger.error{ "Error running test suite: #{e.inspect}" }
      false
    end

    def server_spawner
      @server_spawner ||= ServerSpawner.new(port: Configuration.port)
    end

    def watch_for_changes
      require 'listen'

      @listener = Listen.to(project_root)

      # Match .coffee files in any project paths
      @listener.filter Regexp.new('^(' + all_paths.map{ |s| Regexp.escape s}.join('|') + ')\/.*\.coffee$')

      @listener.change { run_suite }
      @listener.start false
    end

    def shut_down(status=0)
      @listener.stop if @listener
      @browser.close if @browser
      @server_spawner.stop if @server_spawner
      exit status
    end

    def trap_sigint
      trap('SIGINT') do
        puts "Shutting down..."
        shut_down
      end
    end

  end
end
