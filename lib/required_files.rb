require 'tsort'

class RequiredFiles < Hash
  include TSort
  
  attr_accessor :paths
  
  # Adds a file to required list, and recursively scans and adds all other
  # files required by this file
  def add name
    file_name = full_path name
    if file_name && !self[name.to_sym]
      directives = parse_directives file_name
      self[name.to_sym] = {
        :file_name  => file_name,
        :requires   => directives['require']
      }
      requested = (directives['require'] | directives['request'])
      requested.each{ |file| add file }
    end
  end

  # Gets an array of file paths sorted in dependency order
  def sorted_files
    tsort.map{ |key| self[key][:file_name] }
  end
  
  private
    # Searches for file in path with given name and returns full file path,
    # or nil if not found
    def full_path name
      file_path = @paths.find { |path| File.exists? "#{path}/#{name}.coffee" }
      raise "File not found: #{name}" unless file_path
      file_path && "#{file_path}/#{name}.coffee"
    end
  
    # Scans a coffeescript file for #require and #request directives.
    #
    # Example requirement directives:
    #   #require ST
    #   #require ST/Model/Index
    def parse_directives name
      directives = {
        'require' => [],
        'request' => []
      }
      File.open name do |file|
        file.each do |line|
          if line.match /^#(require|request)\s+(\S+)\s*$/
            directives[$1] << $2
          end
        end
      end
      directives
    end
  
    # Callback functions for tsort
    alias tsort_each_node each_key
    def tsort_each_child node
      self[node][:requires].each{ |name| yield name.to_sym }
    end
end