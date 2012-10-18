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
      @animation = Chingu::Animation.new( bounce: true, file: 'pc.png', size: 100, delay: 250)
      @animation.frame_names = {down: (0..2), up: (3..5), left: (6..8), right: (9..11)}
      @current_dir = :down
      super(options.merge(:image => @animation[@current_dir][1]))
      @gesture_symbols = []
      @spell_book = Databases::SpellBook.new
      @speed = 3
      @level = options[:level]
    end

    def update
      super
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
