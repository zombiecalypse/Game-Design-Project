require 'rubygems'
require 'chingu'
require 'gosu'

module Levels
  class StartMenu < Chingu::GameState
  end

  class TestLevel < Chingu::GameState
    def initialize(opts = {})
      super(opts)
      @player = Objects::Player.create
    end

    def setup
      super
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

  end
end
