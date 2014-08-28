module Gusto
  module Sprockets
    class << self
      # Prepares a Sprockets::Environment object to serve coffeescript assets
      def environment
        @environment ||= ::Sprockets::Environment.new.tap do |environment|
          configure_environment(environment)
          load_sprockets_extensions(environment)
        end
      end

      private

      def configure_environment(environment)
        FileUtils.mkdir_p(Configuration.cache_path) unless File.exist?(Configuration.cache_path)
        environment.cache = ::Sprockets::Cache::FileStore.new(Configuration.cache_path)
        environment.logger = Gusto.logger
        environment.append_path File.join(Gusto.root, 'lib')
        environment.append_path File.join(Gusto.root, 'assets')
        Gusto.logger.debug { "Using assets in #{all_paths.inspect}" }
        all_paths.each{ |path| environment.append_path(path) }
      end

      def load_sprockets_extensions(environment)
        if Configuration.sprockets_extensions
          Gusto.logger.debug { "Loading sprockets extensions from #{Configuration.sprockets_extensions}" }
          extensions = File.read(Configuration.sprockets_extensions)
          environment.instance_eval extensions
        end
      end

      def all_paths
        Configuration.lib_paths + Configuration.spec_paths
      end
    end
  end
end
