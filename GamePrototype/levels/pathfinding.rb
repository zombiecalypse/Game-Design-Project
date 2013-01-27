module Pathfinding
  class BFS
	  attr_accessor :path
	    
	  def initialize start, goal, nodes
	     @nodes = nodes
	     start_pos = Pos.new(((start.x - 16)/32.0).round * 32 + 16, ((start.y - 16)/32.0).round * 32 + 16)
	     @root = pos_to_node start_pos
	     goal_pos = Pos.new(((goal.x - 16)/32.0).round * 32 + 16, ((goal.y - 16)/32.0).round * 32 + 16)
	     @goal_node = pos_to_node goal_pos
	     biuld_tree
	     @path = biuld_path
	  end
	  
	  def biuld_tree
	    clean_up
	    @queue = [@root]
	    while not @queue.empty? do
	      current_node = @queue.shift
	      @queue = @queue + bfs(current_node)
	      return unless @goal_node.d == -1
	    end
	  end
	  
	  def biuld_path
	    path = [@goal_node.pos]
	    current_node = @goal_node
	    while current_node.parent? do
	      path << current_node.pos
	      current_node = current_node.parent
	    end
	    return path.reverse
	  end
	  
	  def bfs node
	    new_nodes = []
	    node.neighbours.each{|n|
	      if ((node.d + node.distance(n)) < n.d || n.d == -1)
	        n.d = node.d + node.distance(n)
	        if (n.parent?)
	          n.parent.children.delete(n)
	        end
	        n.parent = node
	        new_nodes << n
	      end
	    }
	    node.children = new_nodes
	    return new_nodes
	  end
	  
	  def clean_up
	    @nodes.each{|n| 
	      n.d = -1
	      n.parent = nil
	      n.children = []
	    }
	    @root.d = 0
	  end
	  
	  def pos_to_node pos
	    result = nil
	    @nodes.each{|n| result = n if n.pos.equal? pos}
	    @nodes.each{|n| result = n if n.pos.distance(pos) < 46} unless result
	    return result
	  end
	end
  
  class Node
	  attr_accessor :pos, :parent, :children, :neighbours, :d
  
    def initialize parent, pos
    	@pos = pos
      @parent = parent
      @children = []
      @neighbours = []
    end
    	
    def parent?
    	return (not @parent.nil?)
    end
    
    def line_blocked?(node, level)
      distance = [(node.pos.x - pos.x).abs , (node.pos.y - pos.y).abs].max
      for i in 0..distance
        c_x = Integer(pos.x + i*(Float(node.pos.x - pos.x)/distance))
        c_y = Integer(pos.y + i*(Float(node.pos.y - pos.y)/distance))
        return true if level.blocked? c_x, c_y
      end
      return false
    end
  	
  	def distance other
  	  Math.sqrt((other.pos.x - pos.x)**2 + (other.pos.y - pos.y)**2)
  	end
  	
    def to_s
    	return pos.to_s
    end
  end
    
  class Pos
	  attr_accessor :x, :y
    	
    def initialize x, y
  	  @x = x.round
      @y = y.round
    end
    
    def distance other
      Math.sqrt((other.x - @x)**2 + (other.y - @y)**2)
    end
    	
    def equal? other
  	  return x == other.x && y == other.y
    end
    	
    def to_s
    	return "(#{x},#{y})"
    end
  end
end
