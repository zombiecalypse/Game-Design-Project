require 'rubygems'
require 'rspec'
require 'chingu'
require 'gosu'
require 'logger'
def relative(*path)
  File.join(File.expand_path(File.dirname(__FILE__)), *path)
end
