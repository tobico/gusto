module Gusto
  module Sprockets
    class << self
      # Prepares a Sprockets::Environment object to serve coffeescript assets
      def environment
        @environment ||= ::Sprockets::Environment.new.tap do |environment|
          configure_environment(environment)
        end
      end

      private

      def configure_environment(environment)
        environment.append_path File.join(Gusto.root, 'lib')
        environment.append_path File.join(Gusto.root, 'assets')
        puts "Using assets in #{Gusto.all_paths.inspect}"
        Gusto.all_paths.each{ |path| environment.append_path(path) }
      end
    end
  end
end
