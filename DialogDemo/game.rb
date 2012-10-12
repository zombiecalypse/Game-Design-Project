# /usr/bin/env ruby

require 'rubygems'
require 'chingu'
include Gosu

class Game < Chingu::Window
	def initialize
		super
		self.input = {:escape => :exit}
	end
	
	def draw
		super
		Image["background.png"].draw(0,0,0)
		Image["dialog_box.png"].draw(0,440,0)
	end
end

Game.new.show

