require 'rubygems'
require 'chingu'
require 'gosu'
require 'logger'


module Levels
  class TestLevel < Chingu::GameState
    trait :viewport
    def initialize(opts = {})
      super(opts)
      @level_width = 1000
      @level_height = 1000
      self.viewport.lag = 0
      self.viewport.game_area = [0.0, 0.0, @level_width, @level_height]
      @log = Logger.new(STDOUT)
      @camera = @player = Objects::Player.create x: 550, y: 550, level: self
      log_info { "entering" }
    end

    def finalize
      log_info { "exiting" }
    end

    def log_info &block
      @log.info("TestLevel", &block)
    end

    def blocked? x,y
      return true if x < 0 or y < 0
      return true if x > @level_width or y > @level_height
    end

    def can_move_to? x,y
      not blocked? x,y
    end

    def setup
      super
      self.input = {
        esc:                   :open_menu
      }
      @player.input = { 
        holding_a:             :move_left, 
        holding_d:             :move_right, 
        holding_w:             :move_up,
        holding_s:             :move_down,
        mouse_left:            :new_word,
        holding_mouse_right:   :record_gesture,
        mouse_right:           :new_gesture,
        released_mouse_right:  :finished_gesture}
    end

    def open_menu
      pop_game_state
    end
    
    def draw
      draw_background
      viewport.center_around @camera
      super
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
