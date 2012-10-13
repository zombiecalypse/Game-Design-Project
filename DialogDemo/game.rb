# /usr/bin/env ruby

require 'rubygems'
require 'chingu'
include Gosu

require_relative 'dialog.rb'

class Game < Chingu::Window
	attr_accessor :dialog
	
	def initialize ( d )
	  super(800,600,false)
	  self.input = {:escape => :exit, :mouse_left => :left_click}
	  @quesiton_color = Color.new(0xFF000000)
	  @answer_color = Color.new(0xFFFFFFFF)
	  @dialog = d
	  update_question
	end
	
	def draw
	  super
	  Image["background.png"].draw(0,0,0)
	  Image["dialog_box.png"].draw(0,440,0)
	end
	
	def update
	  super
	  self.caption = "#{mouse_x.to_s} #{mouse_y.to_s}"  
	end
	
	def left_click
	  answer = case mouse_y
	    when 481..520 then 1
	    when 521..560 then 2
	    when 561..600 then 3
	    else 0
	  end
	  if answer != 0
	  	@dialog = @dialog.answer answer
	  	if @dialog.nil? 
	  		puts "nil"
	  		exit
	  	end
	  	update_question
	  end   
	end
	
	def update_question
	  Chingu::Text.destroy_all
	  Chingu::Text.create(@dialog.question, :x => 0, :y => 440, :size => 30, :color => @question_color)
	  Chingu::Text.create(@dialog.answer1, :x => 0, :y => 480, :size => 30, :color => @answer_color)
	  Chingu::Text.create(@dialog.answer2, :x => 0, :y => 520, :size => 30, :color => @answer_color)
	  Chingu::Text.create(@dialog.answer3, :x => 0, :y => 560, :size => 30, :color => @answer_color)
	end
		
	
	def needs_cursor?; true; end
		
	  
end
dialog1 = Dialog.new("What's your name?", "Claudio", "Aaron", "The Chosen One")
game = Game.new dialog1
dialog2 = Dialog.new("What do you want to do?", "Code", "Program", "Kill a dragon")
dialog1.next_dialog = dialog2
game.show

