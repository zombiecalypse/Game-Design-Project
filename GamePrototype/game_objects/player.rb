require 'rubygems'
require 'chingu'
require 'gosu'

require_relative '../databases/spellbook'
require_relative '../inputs/gesture_controller'

module Objects
  class Player < Chingu::GameObject
    def initialize(options = {})
      super(options.merge(:image => Gosu::Image['player.png']))
      @gesture_symbols = []
      @spell_book = Databases::SpellBook.new
    end

    def move_left
      @x -= 2
    end

    def move_right
      @x += 2
    end

    def move_up
      @y -= 2
    end

    def move_down
      @y += 2
    end

    def new_gesture
      @gesture_buffer = Inputs::GestureBuffer.new
    end

    def record_gesture
      @gesture_buffer.dot
    end

    def finished_gesture
       @gesture_symbols << @gesture_buffer.read
       spell = @spell_book.lookup @gesture_symbols
       if spell
         spell.run self
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
