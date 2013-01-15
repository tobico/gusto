# encoding: UTF-8

require 'sinatra'
require 'slim'
require 'coffee-script'
require File.expand_path(File.dirname(__FILE__) + '/../seaweed')

module Seaweed
  class Server < Sinatra::Application
    # Configure paths
    set :public_folder,   ROOT + '/public'
    set :views,           ROOT + '/views'

    # Configure slim for prettier code formatting
    Slim::Engine.set_default_options :pretty => true

    # Hide redundant log messages
    disable :logging
    
    # Processes request for page index
    get "/" do
      # Fetch list of all specification files in specs path
      @scripts = []
      Seaweed.specs.each do |path|
        Dir["#{Seaweed::PROJECT_ROOT}/#{path}/**/*.spec.coffee"].each do |file|
          @scripts << $1 if file.match Regexp.new("^#{Regexp.escape Seaweed::PROJECT_ROOT}\\/#{Regexp.escape path}\\/(.*).coffee$")
        end
      end
      
      render :slim, :index
    end
  end
end
