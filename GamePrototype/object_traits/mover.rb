require 'logger'
require_relative '../helpers/dist'

module Chingu::Traits
  # Type of enemy that moves towart the player and hits them.
  module Mover
    module ClassMethods
      def initialize_trait(options={})
        trait_options[:mover] = options
      end

      def blocked_if &blk
        trait_options[:mover][:blocked_if] = blk
      end
    end

    attr_reader :speed

    def blocked_block
      trait_options[:mover][:blocked_if]
    end

    def blocked? x,y
      self.instance_exec(x,y, &blocked_block) if blocked_block
    end

    def setup_trait(opts={})
      @speed = trait_options[:mover][:speed] || 6
      @goal_distance = 10
      super opts
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
      return if (dist - @goal_distance).abs < speed
      if dist < @goal_distance
        phi = Math.atan2(y - @goal.y, x - @goal.x) # Directly away from point
        dx = Math.cos(phi) * speed
        dy = Math.sin(phi) * speed
        return if blocked?(@x+dx, @y+dy)
        @x += dx
        @y += dy
        on_move dx, dy
      else
        if P[@goal.x,@goal.y] != @old_goal_position
          @path = recalculate_path_to @goal if (@path.nil? || @path.empty?)
          @old_goal_position = P[@goal.x, @goal.y]
        end

        move_along_path
      end
    end

    def on_move dx,dy; end

    # fill AI here, seriously... do!
    def recalculate_path_to g
      bfs = Pathfinding::BFS.new(Pathfinding::Pos.new(x,y),g,parent.nodes)
      @path = bfs.path
    end

    def move_along_path
      first = @path[0]
      return if not first
      if d(self, first) < speed # wont loop but assumes 
        @path = @path[1..-1]    # well-behaved suroundings
        move_along_path
      else
        phi = Math.atan2(first.y - y, first.x - x) # Directly at point
        dx = Math.cos(phi) * speed
        dy = Math.sin(phi) * speed
        return if blocked?(@x+dx, @y+dy)
        @x += dx
        @y += dy
        on_move dx, dy
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
