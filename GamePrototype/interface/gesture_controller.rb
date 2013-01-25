require 'rubygems'
require 'chingu'
require 'gosu'

require_relative '../game_objects/player'
module Interface
  class GestureBuffer
    class << self
      def gesture name, priority, &block
        @gestures ||= []
        @gestures << [name, priority, block]
        @gestures = @gestures.sort_by {|_, p, _| -p}
      end

      def recognize xs, ys
        @gestures
          .select {|name, _, block| block.call(xs,ys)}
          .collect(&:first)[0]
      end
    end

    gesture :left, 0 do |xs, ys|
      x,y = xs[-1]-xs[0], ys[-1]-ys[0]
      x < 0 and x.abs > y.abs
    end

    gesture :right, 0 do |xs, ys|
      x,y = xs[-1]-xs[0], ys[-1]-ys[0]
      x > 0 and x.abs > y.abs
    end

    gesture :down, 0 do |xs, ys|
      x,y = xs[-1]-xs[0], ys[-1]-ys[0]
      y > 0 and x.abs < y.abs
    end

    gesture :up, 0 do |xs, ys|
      x,y = xs[-1]-xs[0], ys[-1]-ys[0]
      y < 0 and x.abs < y.abs
    end

    def initialize(window = $window)
      @buffer = []
      @window = window
    end

    def dot
      @buffer << [@window.mouse_x, @window.mouse_y]
    end

    def read
      return @cached if @cached
      
      xs, ys = @buffer.transpose

      return nil if xs.nil? or xs.size < 5
      
      self.class.recognize(xs,ys) rescue nil
    end
  end
end
