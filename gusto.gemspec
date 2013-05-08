# -*- encoding: utf-8 -*-
require File.expand_path('../lib/gusto/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name = "gusto"
  spec.version = Gusto::VERSION

  spec.summary = "Coffeescript testing framework"
  spec.description = "Gusto is Coffeescript behavioral testing framework, with a command line tool that can be used to run specs automatically."
  spec.license = 'MIT'
  spec.homepage = "https://github.com/tobico/gusto"
  spec.author = "Tobias Cohen"
  spec.email = "me@tobiascohen.com"

  spec.files = [
    Dir['assets/**/*'],
    ['bin/gusto'],
    Dir['lib/**/*'],
    Dir['public/*'],
    Dir['views/*']
  ].flatten
  spec.executables = ['gusto']
  spec.add_dependency "coffee-script"
  spec.add_dependency "json"
  spec.add_dependency "sprockets"
  spec.add_dependency "sinatra"
  spec.add_dependency "sass"
  spec.add_dependency "slim"
  spec.add_dependency "selenium-webdriver"
  spec.add_dependency "listen"
end
