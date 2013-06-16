module Gusto
  module Configuration
    class << self
      def paths
        [
          File.join(Gusto.project_root, 'gusto.json'),
          File.join(Gusto.project_root, 'config', 'gusto.json')
        ]
      end

      def load
        # Set configuration defaults
        @data = {
          'port'        => 4567,
          'lib_paths'   => %w(lib),
          'spec_paths'  => %w(spec)
        }

        # Load custom configuration file
        paths.each do |path|
          if File.exists? path
            @data.merge! JSON.parse(File.read(path))
            puts "Loaded configuration from “#{path}”"
          end
        end
      end

      def port
        @data['port']
      end

      def port= value
        @data['port'] = value
      end

      def lib_paths
        @data['lib_paths']
      end

      def spec_paths
        @data['spec_paths']
      end
    end
  end
end
