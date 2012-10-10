require 'rubygems'
require 'chingu'
require 'gosu'
module Inputs
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

    gesture :top_arc, 10 do |xs, ys|
      x,y = xs[-1]-xs[0], ys[-1]-ys[0]
      half = xs.size/2
      x_1, y_1 = [xs,ys].collect{|c| c[half] - c[0]}
      x_2, y_2 = [xs,ys].collect{|c| c[-1] - c[half]}
      y_1 < -(x.abs/3) and y_2 > (x.abs/3)
    end

    def initialize
      @buffer = []
    end

    def dot
      @buffer << [$window.mouse_x, $window.mouse_y]
    end

    def read
      return @cached if @cached
      
      xs, ys = @buffer.transpose
      
      self.class.recognize(xs,ys)
    end
  end
end
