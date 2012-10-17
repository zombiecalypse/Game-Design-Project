require 'rubygems'
require 'chingu'
require 'gosu'

require_relative '../databases/spellbook'
require_relative '../inputs/gesture_controller'

module Objects
  class Player < Chingu::GameObject
    trait :bounding_box, debug: true
    trait :collision_detection
    def initialize(options = {})
      super(options.merge(:image => Gosu::Image['player.png']))
      @gesture_symbols = []
      @spell_book = Databases::SpellBook.new
      @speed = 3
      @level = options[:level]
    end

    def move_left
      @x -= @speed unless @level and @level.blocked? @x-@speed, @y
    end

    def move_right
      @x += @speed unless @level and @level.blocked? @x+@speed, @y
    end

    def move_up
      @y -= @speed unless @level and @level.blocked? @x, @y-@speed
    end

    def move_down
      @y += @speed unless @level and @level.blocked? @x, @y+@speed
    end

    def new_gesture
      @gesture_buffer = Inputs::GestureBuffer.new
    end

    def record_gesture
      @gesture_buffer.dot
    end

    def finished_gesture
       @gesture_symbols << @gesture_buffer.read
       spell_class = @spell_book.lookup @gesture_symbols
       if spell_class
         spell_class.create.run(self)
         new_word
       end
       return if @gesture_symbols == []
       back = [[Databases::SpellBook.depth, @gesture_symbols.length].min, 1].max
       @gesture_symbols = @gesture_symbols[-back..-1]
    end

    def new_word
      @gesture_symbols = []
    end
  end
end
