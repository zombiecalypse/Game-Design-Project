class Sword < Weapon
  class Swing < Chingu::Particle
    traits :velocity, :collision_detection
    trait :attack, enemies: Enemies::all, damage: 3, speed: 3, range: 15
    trait :bounding_circle, scale: 0.25

    def initialize(opts={})
      super({image: 'slash.png', rotation_rate: 3, scale: 0.4, mode: :default, angle: (opts[:dir]/Math::PI * 180)}.merge! opts)
    end
  end
  def attack x,y
    player = the Objects::Player
    dx = x - player.x_window
    dy = y - player.y_window
    phi = Math::atan2(dy,dx)
    swing = Swing.create x: player.x+20*Math::cos(phi), y: player.y+20*Math::sin(phi), dir: phi
  end
end
