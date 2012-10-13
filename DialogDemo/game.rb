# /usr/bin/env ruby

require 'rubygems'
require 'chingu'
include Gosu

class Game < Chingu::Window
	def initialize
		super
		@str = "no answer"
		self.input = {:escape => :exit}
		self.input = {:mouse_left => :left_click}
	end
	
	def draw
		super
		Image["background.png"].draw(0,0,0)
		Image["dialog_box.png"].draw(0,440,0)
	end
	
	def update
	      super
	      self.caption = "#{@str} #{mouse_x.to_s} #{mouse_y.to_s}"
	      
	end
	
	def left_click
	  answer = case mouse_y
	    when 481..520: 1
	    when 521..560: 2
	    when 561..600: 3
	  end
	  @str = "You chose answer number #{answer}"
	      
	end
	
	def needs_cursor?; true; end
		
	  
end

Game.new.show

