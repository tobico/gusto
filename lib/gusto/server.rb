# encoding: UTF-8

require 'sinatra'
require 'sass'
require 'slim'
require 'coffee-script'
require 'sprockets'
require 'sprockets-helpers'
require File.expand_path(File.dirname(__FILE__) + '/../gusto')

module Gusto
  class Server < Sinatra::Application
    def self.start(host, port)
      options = {
        app:    rack_app,
        server: 'webrick',
        Host:   host,
        Port:   port,
      }
      options[:AccessLog] = [] unless Gusto.verbose
      Rack::Server.start options
    end

    def self.rack_app
      Rack::Builder.app do
        map('/assets') { run Sprockets.environment }
        map('/')       { run Server }
      end
    end

    # Configure paths
    set :public_folder,   File.join(Gusto.root, 'public')
    set :views,           File.join(Gusto.root, 'views')
    set :assets_prefix,   '/assets'

    # Configure slim for prettier code formatting
    Slim::Engine.set_default_options :pretty => true

    # Hide redundant log messages
    # disable :logging

    ::Sprockets::Helpers.configure do |config|
      config.environment = Sprockets.environment
      config.public_path = public_folder
      config.prefix      = assets_prefix
      config.debug       = true
    end

    helpers do
      include ::Sprockets::Helpers
    end

    # Processes request for page index
    get "/" do
      Gusto.logger.debug{ "Rendering index page with params #{params.inspect}" }

      # Fetch list of all specification files in specs path
      @scripts = []
      Gusto::Configuration.spec_paths.each do |path|
        Dir["#{Gusto.project_root}/#{path}/**/*spec.coffee"].each do |file|
          if file.match Regexp.new("^#{Regexp.escape Gusto.project_root}\\/#{Regexp.escape path}\\/(.*).coffee$")
            @scripts << $1 
          else
            raise "Scripts file detected with unexpected path: #{file}"
          end
        end
      end
      if params[:filter]
        @scripts = @scripts.select{|file| file.downcase.include? params[:filter].downcase}
      end
      @headless = params[:headless]
      render :slim, :index
    end

    get "/health_check" do
      status 200
    end
  end
end
