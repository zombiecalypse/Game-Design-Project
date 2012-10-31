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

=begin
    def self.circ? xs,ys
      begin
        xavg,yavg = xs.inject(&:+)/xs.size, ys.inject(&:+)/ys.size
        rel_xs, rel_ys = xs.collect {|x| x - xavg}, ys.collect {|y| y - yavg}
        radi = rel_xs.zip(rel_ys).collect {|x,y| Math::hypot(x,y)}
        avg_r = radi.inject(&:+)/radi.size
        std_der = radi.collect{|r| (r-avg_r)**2}.inject(&:+)/(radi.size * (radi.size-1))/avg_r**2
        p std_der
        return nil if std_der.nan?
        std_der < 0.009
      rescue 
        nil
      end
    end
=end

    gesture :top_arc, 10 do |xs, ys|
      my = ys[ys.size/2]
      d = (xs[-1]-xs[0]).abs

      if d > 30
        dy0 = (my - ys[0])/d
        dyn = (my - ys[-1])/d
        dy0 < -0.3 and dyn < -0.3
      end
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

      return nil if xs.size < 5
      
      self.class.recognize(xs,ys)
    end
  end
end
