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
require_relative 'tilemap'
require_relative 'pathfinding'
require_relative '../helpers/logging'

module Levels
  class Level < Chingu::GameState

    # Overwrite, if there is state in the level
    def extract_info
      {}
    end

    def load_info info
    end
    include Modularity::Does
    does "helpers/logging"
    trait :viewport

    attr_reader :song, :map, :nodes

    # Preloading stuff
    #
    # Depending on the class definiton, loads
    #
    # [map] It creates a map, that has been input via either
    #       * `map do ... end`
    #       * defining `create_map`
    # [objects] If the map defines located objects, then there can be 
    #           a callback, that is executed for every such point. This
    #           is done by either
    #       * `on(:obj) do |x,y| ... end`
    #       * setting `clazz.object_callback[:obj]` explicitly
    # [song] If a song is given, it will be loaded and played when the level
    #        loads. A song is given by either
    #       * `music 'filename.ogg'`
    #       * overwriting `self.song_file`
    # [zones] are coloured areas on the mask, that define, what kind of event
    #         starts, when the player enters that place. The RGB values are
    #         defined on the map, but the key is translated to a callback here.
    #         This can be defined by either
    #       * `zone(:trap) do ... end`
    #       * setting `clazz.zones[:trap]` explicitly
    def initialize(opts = {})
      super(opts)
      load_info opts[:infos]
      initialize_map
      initialize_objects if @map
      initialize_song(opts[:song] || song_file)
      initialize_pathfinding
      @camera = opts[:camera]
    end


    def camera
      @camera ||= the(Objects::Player)
    end

    def setup
      super
      self.viewport.lag = 1
      self.viewport.game_area = [0.0, 0.0, map.width, map.height]
      song.play(true) if song
      self.define_inputs
    end

    def define_inputs
      self.input = {
        esc:                   :open_menu,
        F1:                    :debug_state
      }
    end

    def blocked? x,y
      return true if x < 0 or y < 0
      return true if x >= map.width or y >= map.height
      return true if map.blocked? x,y 
    end

    def can_move_to? x,y
      not blocked? x,y
    end

    def enter x,y
      event = map.at(x,y)
      self.instance_exec(&zones[event]) if event and zones[event]
    end

    def healing_blocked?
      false
    end

    def open_menu
      push_game_state PauseMenu
    end

    def update
      super
      self.viewport.center_around camera
      the(PlayerDaemon).update
    end

    def [] teleport
      map.startpoints[teleport]
    end

    class << self
      attr_reader :map_block, :song_file, :zones, :object_callbacks, :tilemap_file

      def map &b
        throw "Already defined map for #{self}" if @map_block or @tilemap_file
        @map_block = b
      end

      def tilemap f
        throw "Already defined map for #{self}" if @map_block or @tilemap_file
        @tilemap_file = f
      end

      def music song
        throw "Already defined music for #{self}" if @song_file
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

      def create_on(opts={})
        @object_callbacks ||= {}
        opts.each_pair do |sym, clazz|
          @object_callbacks[sym] = proc {|x,y| clazz.create x: x, y: y}
        end
      end
    end

    def debug_state
      push_game_state Chingu::GameStates::Debug
    end

    def draw
      super
      the(PlayerDaemon).hud.draw
      @map.draw
    end

    # Can be overwritten, if weapons are not allowed in level (e.g. town)
    def attack?
      true
    end

    private 
    def map_block
      self.class.map_block 
    end

    def self.once sym, &b
      zone sym do
        @seen ||= {}
        next if @seen[sym]
        instance_exec(&b)
        @seen[sym] = true
      end
    end

    def tilemap_file
      self.class.tilemap_file
    end

    def song_file
      self.class.song_file
    end 

    def object_callbacks
      self.class.object_callbacks
    end 

    def zones
      self.class.zones
    end

    def create_map?
      self.respond_to? :create_map
    end

    def initialize_map
      if map_block
        log_debug { "Loading map" }
        @map = Map.create(&map_block)
      elsif tilemap_file
        log_debug { "Loading tilemap" }
        @map = Tilemap[tilemap_file]
        @map.viewport = self.viewport
      elsif create_map?
        log_debug { "Creating map" }
        @map = create_map
      end
      log_debug { "Got map #{@map}" }
    end

    def initialize_objects
      log_debug { "Load objects" }
      @map.objects.each_pair do |key, instances|
        next unless object_callbacks and object_callbacks[key]
        log_debug { "Load all #{key}" }
        instances.each do |e| 
          self.instance_exec(e, &object_callbacks[key])
        end
      end
    end

    def initialize_song song_name
      if song_name
        log_debug { "Loading song #{song_name}" }
        @song = Gosu::Song[song_name]
        log_debug { "Got song #{@song}" }
      end
    end
    
    def initialize_pathfinding
    	@nodes = []
    	mapper = Array.new((@map.width-16)/32 + 2) {Array.new((@map.height-16)/32 + 2)}
    	(16..@map.width).step(32) { |i|
    		(16..@map.height).step(32) { |j|
    			if (not blocked? i, j)
    				@nodes << Pathfinding::Node.new(nil,Pathfinding::Pos.new(i,j))
    				mapper[(i-16)/32][(j-16)/32] = @nodes[-1]
    			end
    		}
    	}
    	@nodes.each{|n|
    	  current_node = mapper[(n.pos.x-16)/32 - 1][(n.pos.y-16)/32 - 1]
     	  n.neighbours << current_node if (current_node && not(n.line_blocked?(current_node,self)))
     	  current_node = mapper[(n.pos.x-16)/32][(n.pos.y-16)/32 - 1]
     	  n.neighbours << current_node if (current_node && not(n.line_blocked?(current_node,self)))
     	  current_node = mapper[(n.pos.x-16)/32 + 1][(n.pos.y-16)/32 - 1]
     	  n.neighbours << current_node if (current_node && not(n.line_blocked?(current_node,self)))
     	  current_node = mapper[(n.pos.x-16)/32 + 1][(n.pos.y-16)/32]
     	  n.neighbours << current_node if (current_node && not(n.line_blocked?(current_node,self)))
     	  current_node = mapper[(n.pos.x-16)/32 + 1][(n.pos.y-16)/32 + 1]
     	  n.neighbours << current_node if (current_node && not(n.line_blocked?(current_node,self)))
     	  current_node = mapper[(n.pos.x-16)/32][(n.pos.y-16)/32 + 1]
     	  n.neighbours << current_node if (current_node && not(n.line_blocked?(current_node,self)))
     	  current_node = mapper[(n.pos.x-16)/32 - 1][(n.pos.y-16)/32 + 1]
     	  n.neighbours << current_node if (current_node && not(n.line_blocked?(current_node,self)))
     	  current_node = mapper[(n.pos.x-16)/32 - 1][(n.pos.y-16)/32] 
     	  n.neighbours << current_node if (current_node && not(n.line_blocked?(current_node,self)))
    	}
    	log_debug {"loaded #{@nodes.size} nodes"}
    end
  end
end
