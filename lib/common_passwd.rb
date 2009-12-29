require "pp"
require "fastercsv"
require "yaml"

class CommonPasswd  < ApplicationController
  # This is a class wrapper around converting a CSV -> YML file we maintain
  # of common passwords we don't want to allow our users to use
  # because we think they're be vulnerable to easy guessing/dictionary attacks
  # In theory, after loading, it should be O(1) to check this list 
  def initialize()
   pp RAILS_ROOT
  end
  
  def import_file(import_file, yaml_file)
    file_path = Pathname.new(RAILS_ROOT + "/" + import_file)
    # Sanitize the path (in case of ../, etc)
    file_path = Pathname.new(file_path.cleanpath)
    passwords = Array.new
    FasterCSV.foreach(file_path,"r") do |record|
      password = record[0].strip.downcase
      unless passwords.include?(password)
      passwords.push(password)
      end
    end
    passwords.sort!
    File.open(yaml_file, 'w' ) do |out|
    YAML.dump(passwords, out )
    end
  end
end