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

    # Dynamically compiles coffeescript, first checking to see if it has changed
    def compile source, target
      begin
        # Get modified time of source file
        mtime = File.mtime source
    
        # If compled JavaScript file already exists and is up to date, return the
        # existing file instead of compiling again
        return File.read target if File.exists?(target) && File.mtime(target) == mtime
        
        # Create base dir for compiled file
        FileUtils.mkpath File.dirname(target), :mode => 0777
            
        # Compile CoffeeScript to JavaScript file
        File.open target, 'w' do |f|
          f.write CoffeeScript.compile(File.read source)
        end
    
        # Mark compiled file with same modified date as source
        File.utime mtime, mtime, target
    
        # Return our newly compiled JavaScript
        File.read target
      rescue CoffeeScript::CompilationError => e
        # Display CoffeeScript compilation error in a prettier format
        message = if e.message.match /^SyntaxError: (.*) on line (\d+)\D*$/
          "#{source}:#{$2}".ljust(40) + " #{$1}"
        elsif e.message.match /^Parse error on line (\d+): (.*)$/
          "#{source}:#{$1}".ljust(40) + " #{$2}"
        else
          "#{source} - #{e.message}"
        end
        puts "\e[31m#{message}\e[0m"
    
        # Generate JS to display compilation error on HTML page
        html = "<pre class=\"failed\">#{message}</pre>"
        "$(function(){$(document.body).prepend(#{html.to_json});});"
      end
    end
    
    # Processes request for seaweed Spec library
    get "/Spec.js" do
      compile File.join(Seaweed::ROOT, 'lib', 'Spec.coffee'), "#{Seaweed::PROJECT_ROOT}/tmp/compiled/spec.js"
    end
    
    # Processes request for page index
    get "/" do
      # Build ordered list of required files to run all specs
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