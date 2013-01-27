require_relative 'weapon'
require_relative '../enemies'

class Pistol < Weapon
  class Shot < Chingu::Particle
    trait :bounding_circle
    traits :velocity, :collision_detection
    trait :attack, enemies: Enemies::all, damage: 1, speed: 7, range: 600, destroy_on_hit: true

    def initialize(opts={})
      super({image: 'projectile.png', rotation_rate: 30, scale: 0.2, mode: :default}.merge! opts)
    end
  end

  def attack x,y
    player = the Objects::Player
    dx = x - player.x_window
    dy = y - player.y_window
    Shot.create x: player.x, y: player.y, dir: Math::atan2(dy,dx)
  end
end
