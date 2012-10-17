require 'rubygems'
require 'chingu'
require 'gosu'
require 'logger'


module Levels
  class TestLevel < Chingu::GameState
    trait :viewport
    def initialize(opts = {})
      super(opts)
      self.viewport.lag = 0
      self.viewport.game_area = [0.0, 0.0, 1000.0, 1000.0]
      @log = Logger.new(STDOUT)
      @camera = @player = Objects::Player.create x: 550, y: 550
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
      draw_background
      super
      viewport.center_around @camera
    end

    def draw_background
      fill(Gosu::Color::WHITE)
    end

    def update
      super
      self.viewport.center_around @player
    end

  end
end
