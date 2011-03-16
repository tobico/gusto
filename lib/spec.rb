#!/usr/bin/env jruby
require "rubygems"
require "bundler/setup"
require "coffee-script"
require "celerity"

Dir.mkdir 'compiled' unless File.exists? 'compiled'
raise "Can't create compile directory" unless File.directory? 'compiled'

# Compile coffee scripts
files = Dir['lib/**/*.coffee', 'spec/**/*.coffee']
longest_name = files.map(&:length).max
for file in files
  begin
    mtime = File.mtime file
    
    outfile = file.sub /^(lib|spec)/, 'compiled'
    outfile = outfile.sub /\.coffee$/, '.js'
    
    next if File.exists?(outfile) && File.mtime(outfile) == mtime
    
    dir = outfile.sub /\/[^\/]+$/, ''
    Dir.mkdir dir unless File.exists? dir
    File.open outfile, 'w' do |f|
      f.write CoffeeScript.compile(File.read(file))
    end
    File.utime mtime, mtime, outfile
    puts outfile
  rescue CoffeeScript::CompilationError => e
    if e.message.match /^SyntaxError: (.*) on line (\d+)\D*$/
      puts "\e[31m#{file}:#{$2}".ljust(longest_name + 6) + " #{$1}\e[0m"
    elsif e.message.match /^Parse error on line (\d+): (.*)$/
      puts "\e[31m#{file}:#{$1}".ljust(longest_name + 6) + " #{$2}\e[0m"
    else
      puts "#{file} - #{e.message}"
    end
  end
end

browser = Celerity::Browser.new
browser.goto 'http://localhost/~tobico/SeaTurtle/spec/spec.html#terminal'
puts browser.text