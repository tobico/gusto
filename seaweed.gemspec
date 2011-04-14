Gem::Specification.new do |spec|  
  spec.name = "seaweed"
  spec.version = '0.1.2'

  spec.summary = "Coffeescript testing framework"
  spec.description = "Seaweed is Coffeescript behavioral testing framework, with a command line tool that can be used to run specs automatically."
  spec.license = 'MIT'
  spec.homepage = "https://github.com/tobico/seaweed"
  spec.author = "Tobias Cohen"
  spec.email = "me@tobiascohen.com"

  spec.files = ['bin/seaweed'] + Dir['lib/**/*'] + Dir['public/*'] + Dir['views/*']
  spec.executables = ['seaweed']
  spec.add_dependency "coffee-script"
  spec.add_dependency "json"
  spec.add_dependency "celerity"
  spec.add_dependency "sinatra"
  spec.add_dependency "slim"
  spec.add_dependency "watchr"
end