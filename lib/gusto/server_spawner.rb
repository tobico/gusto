require 'socket'
require 'timeout'

module Gusto
  class ServerSpawner
    attr :port, :quiet
    
    def initialize(options={})
      @port = options[:port]
      @quiet = options.fetch(:quiet, false)
    end

    def host
      '127.0.0.1'
    end

    def spawn
      choose_open_port
      @server = Process.fork do
        close_std_io if quiet
        self.process_name = "gusto server on #{host}:#{port}"
        start_server
      end
      wait_for_server_at root_url
    end

    def terminate
      Process.kill 'TERM', @server if @server
    end

    private

    def choose_open_port
      until port_open?(port)
        puts "Port #{port} is busy, trying #{port + 1} instead"
        @port += 1
      end
    end

    def close_std_io
      $stdout.reopen "/dev/null", "w"
      $stderr.reopen "/dev/null", "w"
    end

    def process_name=(name)
      $0 = name
    end

    def start_server
      Server.start host, port
    end

    def root_url
      "http://#{host}:#{port}/"
    end

    def wait_for_server_at(url)
      Net::HTTP.get URI.parse(url)
    rescue Errno::ECONNREFUSED
      sleep 1
      retry
    end

    def port_open?(port)
      !system("lsof -i:#{port}", out: '/dev/null')
    end
  end
end
