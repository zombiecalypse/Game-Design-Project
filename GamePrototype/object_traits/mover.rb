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
      @path = BFS.new(Pos.new(x,y),g,parent).path;
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
    
    class BFS
    	attr_accessor :path
    	def initialize start, goal, level                           
    		@start = Pos.new(((start.x-16) / 32).round * 32 + 16, ((start.y-16) / 32).round * 32 + 16)
    		@goal = goal
    		@goal_pos = Pos.new(((goal.x-16) / 32).round * 32 + 16, ((goal.y-16) / 32).round * 32 + 16)
    		@level = level
    		t = Node.new(nil, @start)
    		@tiles = [t]
    		@queue = [t]	
    		goal_node = search
    		@path = get_path goal_node
    	end
    	
    	def search
    		current_node = nil
    		new_pos = nil
    		new_node = nil
    		while not @queue.empty? do
    			count = 0
    			current_node = @queue.shift
    			new_pos = Pos.new(current_node.pos.x + 32, current_node.pos.y)
    			if ((not pos_blocked? new_pos) && (not exists? new_pos))
    				new_node = Node.new(current_node, new_pos)
    				if (new_pos.equal? @goal_pos)
    					return new_node
    				end
    				@tiles << new_node
    				@queue << new_node
    			end
    			new_pos = Pos.new(current_node.pos.x - 32, current_node.pos.y)
    			if ((not pos_blocked? new_pos) && (not exists? new_pos))
    				new_node = Node.new(current_node, new_pos)
    				if (new_pos.equal? @goal_pos)
    					return new_node
    				end
    				@tiles << new_node
    				@queue << new_node
    			end
    			new_pos = Pos.new(current_node.pos.x, current_node.pos.y + 32)
    			if ((not pos_blocked? new_pos) && (not exists? new_pos))
    				new_node = Node.new(current_node, new_pos)
    				if (new_pos.equal? @goal_pos)
    					return new_node
    				end
    				@tiles << new_node
    				@queue << new_node
    			end
    			new_pos = Pos.new(current_node.pos.x, current_node.pos.y - 32)
    			if ((not pos_blocked? new_pos) && (not exists? new_pos))
    				new_node = Node.new(current_node, new_pos)
    				if (new_pos.equal? @goal_pos)
    					return new_node
    				end
    				@tiles << new_node
    				@queue << new_node
    			end
    		end
    	end
    	
    	def get_path node
    		current_node = node
    		path = [current_node.pos]
    		while(current_node.parent?)
    			current_node = current_node.parent
    			path << current_node.pos
    		end
    		path.reverse
    	end
    	
    	def exists? pos
    		@tiles.each { |n| return true if pos.equal? n.pos}
    		false
    	end
    	
    	def pos_blocked? pos
    		for i in pos.x-16..pos.x+16
    			for j in pos.y-16..pos.y+16
    				return true if @level.blocked?(i, j)
    			end
    		end
    		false
    	end
    	
    end
    
    class Node
    	attr_accessor :pos, :parent, :children
    	
    	def initialize parent, pos
    		@pos = pos
    		@parent = parent
    		@children = []
    	end
    	
    	def parent?
    		return (not @parent.nil?)
    	end
    	
    	def to_s
    		return pos.to_s
    	end
    end
    
    class Pos
    	attr_accessor :x, :y
    	
    	def initialize x, y
    		@x = x
    		@y = y
    	end
    	
    	def equal? other
    		return x == other.x && y == other.y
    	end
    	
    	def to_s
    		return "(#{x},#{y})"
    	end
    end
    
    private
    def log_debug(&b)
      self.class.log_debug(&b)
    end
  end
end
