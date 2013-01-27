require 'rubygems'
require 'chingu'
require 'gosu'
require 'logger'
require 'singleton'

require_relative '../databases/spellbook'
require_relative '../interface/gesture_controller'
require_relative '../object_traits/hp'
require_relative '../interface/journal'
require_relative '../helpers/the'
require_relative '../helpers/logging'

module Objects
  class Player < Chingu::GameObject
    does "helpers/logging"
    attr_reader :current_dir, :journal, :speed
    attr_accessor :vulnerability
    trait :bounding_box, debug: true
    trait :collision_detection
    trait :asynchronous
    trait :hp, hp: 100
    def initialize(opts = {})
      @current_dir       = opts[:dir]          ||:down
      @speed             = opts[:speed]        ||3
      @hp                = opts[:hp]           ||100
      @vulnerability     = opts[:vulnerability]||1
      @level             = opts[:level]
      @weapon            = opts[:weapon]
      @gesture_symbols   = []
      log_debug { "initialized journal" }
      begin
        @animation = Chingu::Animation.new( bounce: true, file: 'main_char.png', size: 32, delay: 250)
        @animation.frame_names = {down: (0..2), left: (3..5), right: (6..8), up: (9..11)}
        log_debug { "initialized animation frames" }
        super(opts.merge(image: @animation[@current_dir][1], zorder: ZOrder::PLAYER))
      rescue
        log_warn { "failed to initialize animation" }
        super(opts.merge( zorder: ZOrder::PLAYER ))
      end
      log_debug { "initialized rest" }
    end

    def extract_info
      {
        hp: @hp,
        dir: @current_dir,
        speed: @speed,
        vulnerability: @vulnerability
      }
    end
    
    def harm h
      super((h * vulnerability).to_i)
    end

    trait :timer

    def on_harm hrm
      super
      the(PlayerDaemon).update
      log_debug { "ouch! I'm at #{hp}HP" }
    end


    def on_heal hl
      super
      the(PlayerDaemon).update
    end

    def on_kill
      log_debug { "X_x" }
      $window.pop_game_state
    end

    def move_left
      @x -= @speed unless @level and @level.blocked? @x-@speed, @y
      @current_dir = :left
      @image = @animation[@current_dir].next
      @level.enter x,y
    end

    def move_right
      @x += @speed unless @level and @level.blocked? @x+@speed, @y
      @current_dir = :right
      @image = @animation[@current_dir].next
      @level.enter x,y
    end

    def move_up
      @y -= @speed unless @level and @level.blocked? @x, @y-@speed
      @current_dir = :up
      @image = @animation[@current_dir].next
      @level.enter x,y
    end

    def move_down
      @y += @speed unless @level and @level.blocked? @x, @y+@speed
      @current_dir = :down
      @image = @animation[@current_dir].next
      @level.enter x,y
    end

    def new_gesture
      log_debug { "New Gesture" }
      @gesture_buffer = Interface::GestureBuffer.new
    end

    def record_gesture
      @gesture_buffer.dot
    end

    def finished_gesture
      log_debug { "Finished Gesture" }
      @gesture_symbols << @gesture_buffer.read if @gesture_buffer.read
      spell = the(PlayerDaemon).spellbook.lookup @gesture_symbols
      if spell
        log_debug { "Executing #{spell} for gesture #{@gesture_symbols}" }
        spell.run(self)
        new_word
      else
        log_debug { "#{@gesture_symbols} is not a gesture in #{@spell_book.to_s}" }
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
      log_debug { "attacking evil point (#{x}, #{y})" }
      return @spell.activate x,y if @spell
      return @weapon.attack x,y if @weapon
    end

    def new_word
      @gesture_symbols = []
    end

    def current_gesture
      @gesture_symbols.dup
    end

    def self.the
      throw "Weird number of players: #{self.all}" if self.all.size != 1
      self.all.first 
    end
  end
end
