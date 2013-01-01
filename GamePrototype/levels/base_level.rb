require 'rubygems'
require 'chingu'
require 'gosu'
require 'logger'

require_relative '../events/event'
require_relative '../events/conversation'
require_relative '../menu/pause_menu'
require_relative '../game_objects/player'
require_relative '../interface/hud_interface'
require_relative '../interface/z_orders'
require_relative 'map'
require_relative '../helpers/logging'

module Levels
  class Level < Chingu::GameState
    include
    trait :viewport

    attr_reader :song, :map

    # Preloading stuff
    def initialize(opts = {}, &b)
      super(opts)
      @map = Map.create(&self.class.map_definition)
      @song = Gosu::Song[opts[:song]] if opts[:song]
      @camera = opts[:camera] || the(Objects::Player)
    end

    def setup(opts={})
      super opts
      self.viewport.lag = 1
      self.viewport.game_area = [0.0, 0.0, width, height]
      song.play(true) if song
      self.define_inputs
    end

    def define_inputs
      self.input = {
        esc:                   :open_menu,
        F1:                    :debug_state
      }
      the(Player).input = { 
        holding_a:             :move_left, 
        holding_d:             :move_right, 
        holding_w:             :move_up,
        holding_s:             :move_down,
        mouse_left:            :new_word,
        holding_mouse_right:   :record_gesture,
        mouse_right:           :new_gesture,
        mouse_left:            :action,
        released_mouse_right:  :finished_gesture}
    end

    def blocked? x,y
      return true if x < 0 or y < 0
      return true if x > @level_width or y > @level_height
      return true if @map.blocked? x,y 
    end

    def can_move_to? x,y
      not blocked? x,y
    end

    def open_menu
      push_game_state PauseMenu
    end

    def update
      super
      self.viewport.center_around @player
    end
    
    class <<self
      attr_reader :map_definition
      def map &b
        throw "duplicate map definition" if @map_definition
        @map_definition = b
      end
    end
  end
end
