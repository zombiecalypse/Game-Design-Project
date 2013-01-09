def d a, b
  Math.hypot (a.x - b.x), (a.y - b.y)
end

class P
  attr_reader :x,:y
  def initialize x,y
    @x, @y = x,y
  end

  def self.[] x,y
    self.new x,y
  end

  def == o
    return false unless o.kind_of? P
    @x == o.x and @y == o.y
  end
end
