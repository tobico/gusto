require 'socket'
require 'timeout'

module Gusto
  class ServerSpawner
    attr :port
    
    def initialize(options={})
      @port = options[:port]
    end

    def host
      '127.0.0.1'
    end

    def spawn
      choose_open_port
      Gusto.logger.info{ "Starting Gusto server on port #{port}" }
      @server = Process.fork do
        self.process_name = "gusto server on #{host}:#{port}"
        start_server
      end
      wait_for_server_at health_check_url
      Gusto.logger.info{ "Gusto server ready at #{root_url}" }
    end

    def stop
      Process.kill 'INT', @server if @server
    end

    private

    def choose_open_port
      until port_open?(port)
        puts "Port #{port} is busy, trying #{port + 1} instead"
        @port += 1
      end
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

    def health_check_url
      "#{root_url}health_check"
    end

    def wait_for_server_at(url)
      Gusto.logger.debug{ "Waiting for server to respond" }
      begin
        Net::HTTP.get URI.parse(url)
      rescue Errno::ECONNREFUSED
        Gusto.logger.debug{ "Server not responding, retrying" }
        sleep 1
        retry
      end
    end

    def port_open?(port)
      !system("lsof -i:#{port}", out: '/dev/null')
    end
  end
end
