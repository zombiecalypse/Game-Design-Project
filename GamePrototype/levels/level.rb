require 'rubygems'
require 'chingu'
require 'gosu'
require 'logger'
require 'texplay'

require_relative '../events/dsl'
require_relative '../events/tile'
require_relative 'pause_menu'
require_relative '../game_objects/simple_tower'


module Levels
  class Map < Chingu::GameObject
    def initialize opts={}
      super opts
      @mask = opts[:mask] || self.image
    end

    def blocked? x,y
      is_wall?(@mask.get_pixel(x,y)) rescue false
    end

    def is_wall? pixel
      r,g,b,a = pixel
      r < 0.1 and g < 0.1 and b < 0.1 and a > 0.99
    end
  end

  class TestLevel < Chingu::GameState
    trait :viewport
    def initialize(opts = {})
      super(opts)
      @map = Map.create( x: 0, y: 0, \
                        image: Gosu::Image['maps/01_bg.png'], \
                        mask: Gosu::Image['maps/01_mask.png'], \
                        zorder: -1)
      @map.center = 0
      @level_width = 1000
      @level_height = 1000
      self.viewport.lag = 0
      self.viewport.game_area = [0.0, 0.0, @level_width, @level_height]
      @log = Logger.new(STDOUT)
      load_events
      log_info {"Database loaded"}
      @camera = @player = Objects::Player.create x: 550, y: 550, level: self
      @tower = Objects::SimpleTower.create x: 100, y: 100
      log_info { "entering" }
    end

    def load_events
      dialog = Dsl::Event.new(once: true) do |evt|
        evt.on_hit do
          show_popup "I was an adventurer like you"
          show_popup "Until I took a thunderbolt to the knee"
        end
      end

      tile = Events::Tile.create event: dialog, x: 400, y: 300
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
      return true if @map.blocked? x,y
    end

    def can_move_to? x,y
      not blocked? x,y
    end

    def debug_state
      push_game_state Chingu::GameStates::Debug
    end

    def setup
      super
      self.input = {
        esc:                   :open_menu,
        F1:                    :debug_state
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
      push_game_state PauseMenu
    end
    
    def draw
      draw_background
      viewport.center_around @camera
      super
    end

    def draw_background
      fill(Gosu::Color::WHITE, -5)
    end

    def update
      super
      self.viewport.center_around @player
    end

  end
end
