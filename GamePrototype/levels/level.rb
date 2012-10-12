require 'rubygems'
require 'chingu'
require 'gosu'
require 'logger'


module Levels
  class TestLevel < Chingu::GameState
    def initialize(opts = {})
      super(opts)
      @log = Logger.new(STDOUT)
      @player = Objects::Player.create
      @log.info("TestLevel") { "entering" }
    end

    def finalize
      @log.info("TestLevel") { "exiting" }
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
