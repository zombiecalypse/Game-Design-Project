class Weapon
  attr_accessor :player
  def initialize opts={}
    @player = opts[:player]
    @range = opts[:range] || 50
    @damage = opts[:damage] || 2
    @animation = opts[:animation]
  end

  # Spawn attack animation
  def attack point
  end
end
