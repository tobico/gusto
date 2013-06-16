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
    def self.start
      app = Rack::Builder.app do
        map '/assets' do
          run Gusto::Sprockets.environment
        end

        map '/' do
          run Gusto::Server
        end
      end
      Rack::Handler.default.run app, :Port => port
    end

    # Configure paths
    set :public_folder,   File.join(Gusto.root, 'public')
    set :views,           File.join(Gusto.root, 'views')
    set :assets_prefix,   '/assets'

    # Configure slim for prettier code formatting
    Slim::Engine.set_default_options :pretty => true

    # Hide redundant log messages
    disable :logging

    ::Sprockets::Helpers.configure do |config|
      config.environment = Gusto::Sprockets.environment
      config.public_path = public_folder
      config.prefix      = assets_prefix
      config.debug       = true
    end

    helpers do
      include ::Sprockets::Helpers
    end

    # Processes request for page index
    get "/" do
      # Fetch list of all specification files in specs path
      @scripts = []
      Gusto::Configuration.spec_paths.each do |path|
        Dir["#{Gusto.project_root}/#{path}/**/*spec.coffee"].each do |file|
          @scripts << $1 if file.match Regexp.new("^#{Regexp.escape Gusto.project_root}\\/#{Regexp.escape path}\\/(.*).coffee$")
        end
      end

      render :slim, :index
    end
  end
end
