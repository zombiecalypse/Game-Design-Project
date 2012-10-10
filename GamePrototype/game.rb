require 'rubygems'
require 'chingu'
require 'gosu'

require_relative 'inputs/gesture_controller.rb'

class Game < Chingu::Window
  def initialize
    super
    @player = Objects::Player.create
    @player.input = { 
      holding_a: :move_left, 
      holding_d: :move_right, 
      holding_w: :move_up,
      holding_s: :move_down,
      mouse_left: :new_word,
      holding_mouse_right: :record_gesture,
      mouse_right: :new_gesture,
      released_mouse_right: :finished_gesture}
  end
  
  def draw
    fill(Gosu::Color::WHITE)
    super
  end

  def needs_cursor?; true; end
end

Game.new.show
