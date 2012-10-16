# /usr/bin/env ruby

require 'rubygems'
require 'chingu'
include Gosu

require_relative 'dialog.rb'

class Game < Chingu::Window
	def initialize( n )	
		puts n
		super 1
	end
end
	

dialog1 = Dialog.new("What's your name?", "Claudio", "Aaron", "The Chosen One")
game = Game.new "hi"
dialog2 = Dialog.new("What do you want to do?", "Code", "Program", "Kill a dragon")
dialog1.next_dialog = dialog2
