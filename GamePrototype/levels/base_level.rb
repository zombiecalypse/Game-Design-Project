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
    include Modularity::Does
    does "helpers/logging"
    trait :viewport

    attr_reader :song, :map

    def map_block
      self.class.map_block 
    end

    def song_file
      self.class.song_file
    end 

    def object_callbacks
      self.class.object_callbacks
    end 
    # Preloading stuff
    def initialize(opts = {}, &b)
      super(opts)
      if map_block
        log_debug { "Loading map" }
        @map = Map.create(&map_block)
        log_debug { "Got map #{@map}" }
        log_debug { "Load objects" }
        @map.objects.each_pair do |key, instances|
          return unless object_callbacks[key]
          log_debug { "Load all #{key}" }
          instances.each do |e| 
            self.instance_exec(e, &object_callbacks[key])
          end
        end
      end
      song_name = opts[:song] || song_file
      if song_name
        log_debug { "Loading song #{song_name}" }
        @song = Gosu::Song[song_name]
        log_debug { "Got song #{@song}" }
      end
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

    def zones
      self.class.zones
    end

    class <<self
      attr_reader :map_block, :song_file, :zones, :object_callbacks

      def map &b
        @map_block = b
      end

      def music song
        @song_file = song
      end

      def zone sym, &b
        @zones ||= {}
        @zones[sym] = b
      end

      def on sym, &b
        @object_callbacks ||= {}
        @object_callbacks[sym] = b
      end
    end
  end
end
