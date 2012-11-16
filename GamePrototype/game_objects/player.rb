require 'rubygems'
require 'chingu'
require 'gosu'
require 'logger'

require_relative '../databases/spellbook'
require_relative '../interface/gesture_controller'
require_relative '../object_traits/hp'

module Objects
  class Player < Chingu::GameObject
    attr_reader :current_dir
    attr_accessor :vulnerability
    trait :bounding_box, debug: true
    trait :collision_detection
    trait :hp, hp: 100
    def initialize(options = {})
      @animation = Chingu::Animation.new( bounce: true, file: 'pc.png', size: 100, delay: 250)
      @animation.frame_names = {down: (0..2), up: (3..5), left: (6..8), right: (9..11)}
      @current_dir = :down
      @spell_book = Databases::SpellBook.new
      @speed = 3
      @log = Logger.new(STDOUT)
      super(options.merge(:image => @animation[@current_dir][1]))
    end
    
    def setup(opts={})
      @gesture_symbols = []
      @level = options[:level]
      @vulnerability = 1
    end

    def harm h
      super((h * vulnerability).to_i)
    end

    def on_harm hrm
      parent.update_hud
      @log.info("Player") { "ouch! I'm at #{hp}HP" }
    end

    def on_heal hl
      parent.update_hud
    end

    def on_kill
      @log.info("Player") { "X_x" }
      $window.pop_game_state
    end

    def move_left
      @x -= @speed unless @level and @level.blocked? @x-@speed, @y
      @current_dir = :left
      @image = @animation[@current_dir].next
    end

    def move_right
      @x += @speed unless @level and @level.blocked? @x+@speed, @y
      @current_dir = :right
      @image = @animation[@current_dir].next
    end

    def move_up
      @y -= @speed unless @level and @level.blocked? @x, @y-@speed
      @current_dir = :up
      @image = @animation[@current_dir].next
    end

    def move_down
      @y += @speed unless @level and @level.blocked? @x, @y+@speed
      @current_dir = :down
      @image = @animation[@current_dir].next
    end

    def new_gesture
      @log.debug("Player") { "New Gesture" }
      @gesture_buffer = Interface::GestureBuffer.new
    end

    def record_gesture
      @gesture_buffer.dot
      @hu
    end

    def finished_gesture
      @log.debug("Player") { "Finished Gesture" }
      @gesture_symbols << @gesture_buffer.read if @gesture_buffer.read
      spell_class = @spell_book.lookup @gesture_symbols
      if spell_class
        @log.info("Player") { "Executing #{spell_class} for gesture #{@gesture_symbols}" }
        spell_class.create.run(self)
        new_word
      else
        @log.debug("Player") { "#{@gesture_symbols} is not a gesture in #{@spell_book.to_s}" }
      end
      return if @gesture_symbols == []
      back = [[Databases::SpellBook.depth, @gesture_symbols.length].min, 1].max
      @gesture_symbols = @gesture_symbols[-back..-1]
    end

    # Interacts with the environment, for example triggers an attack.
    def action
      x,y = $window.mouse_x, $window.mouse_y

      attack x,y
    end

    attr_accessor :spell

    def x_window
      self.x - @level.viewport.x
    end

    def y_window
      self.y - @level.viewport.y
    end

    def attack x,y
      @log.debug("Player") { "attacking evil point (#{x}, #{y})" }
      @spell.activate x,y if @spell
    end

    def new_word
      @gesture_symbols = []
    end

    def self.the
      throw "Weird number of players: #{self.all}" if self.all.size != 1
      self.all.first 
    end
  end
end
