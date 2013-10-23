# encoding: UTF-8

require 'rubygems'
require 'sprockets'
require 'net/http'
require 'rack'
require 'json'
require File.join(File.dirname(__FILE__), 'gusto', 'version')


module Gusto
  autoload :Configuration,  File.join(File.dirname(__FILE__), 'gusto', 'configuration')
  autoload :Server,         File.join(File.dirname(__FILE__), 'gusto', 'server')
  autoload :Sprockets,      File.join(File.dirname(__FILE__), 'gusto', 'sprockets')
  autoload :CliRenderer,    File.join(File.dirname(__FILE__), 'gusto', 'cli_renderer')

  HEADLESS_RUNNER_PATH =    File.realpath(
    File.join(File.dirname(__FILE__), '..', 'phantom', 'headless_runner.js'))

  class << self
    def root
      File.expand_path File.join(File.dirname(__FILE__), '..')
    end

    def project_root
      File.expand_path "."
    end

    def root_url
      "http://localhost:#{Configuration.port}/"
    end

    def server
      trap_sigint
      spawn_server
      Process.waitall
    end

    def cli
      trap_sigint
      spawn_server(quiet: true)
      result = run_suite?
      shut_down(result ? 0 : 1)
    end

    def autotest
      trap_sigint
      spawn_server
      run_suite?
      watch_for_changes
      Process.waitall
    end

    def spawn_server(options={})
      @server = Process.fork do
        if options[:quiet]
          $stdout.reopen "/dev/null", "w"
          $stderr.reopen "/dev/null", "w"
        end
        $0 = 'gusto server'
        Server.start
      end
      wait_for_server_at(root_url)
    end

    def run_suite?
      json = `phantomjs #{Shellwords.escape HEADLESS_RUNNER_PATH} #{Configuration.port}`
      report = JSON.parse json
      puts CliRenderer.new(report).render
      report['status'] != 2
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
      Net::HTTP.get URI.parse(url)
    rescue Errno::ECONNREFUSED
      sleep 1
      retry
    end
  end
end
