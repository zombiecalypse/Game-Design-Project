require 'logger'

module Chingu::Traits
  # Type of enemy that moves towart the player and hits them.
  module Mover
    module ClassMethods
      def initialize_trait(options={})
        trait_options[:mover] = options
        self.on_notice do |p|
          @goal = p
        end
      end
    end

    attr_reader :speed

    def setup_trait(opts={})
      @speed = trait_options[:mover][:speed] || 6
      @goal_distance = 10
      super opts
    end

    class P
      attr_reader :x,:y
      def initialize x,y
        @x, @y = x,y
      end

      def self.[] x,y
        self.new x,y
      end
    end

    def move_away_from p
      keep_distance p, Float::INFINITY
    end

    def move_to p
      keep_distance p, 0
    end

    def keep_distance p, dist
      @goal = p
      @goal_distance = dist
    end

    def move 
      return unless @goal 
      dist = d(self, @goal)
      return if (dist - @goal_distance).abs < 3*speed
      if dist < @goal_distance
        phi = Math.atan2(y - @goal.y, x - @goal.x) # Directly away from point
        @x += Math.cos(phi) * speed
        @y += Math.sin(phi) * speed
      else
        if P[@goal.x,@goal.y] != @old_goal_position
          @path = recalculate_path_to @goal
          @old_goal_position = P[@goal.x, @goal.y]
        end

        move_along_path
      end
    end

    # fill AI here, seriously... do!
    def recalculate_path_to g
      @path = [g]
    end

    def move_along_path
      first = @path[0]
      return if not first
      if d(self, first) < speed # wont loop but assumes 
        @path = @path[1..-1]    # well-behaved suroundings
        move_along_path
      else
        phi = Math.atan2(first.y - y, first.x - x) # Directly at point
        @x += Math.cos(phi) * speed
        @y += Math.sin(phi) * speed
      end
    end

    def update_trait
      super
      move
    end

    private
    def log_debug(&b)
      self.class.log_debug(&b)
    end
  end
end
