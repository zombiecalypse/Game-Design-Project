require_relative 'spell'

class ShockWave < Chingu::Particle
  include Modularity::Does
  trait :bounding_circle, debug: true
  traits :velocity, :collision_detection
  trait :attack, enemies: Enemies::all, damage: 0, speed: 0, range: 300

  does 'helpers/logging'

  def initialize(opts={})
    super({image: 'projectile.png', rotation_rate: 30, fade_rate:  -5, scale_rate: 0.75, alpha: 160}.merge! opts)
    @player = opts[:player]
  end

  def update
    super
    self.destroy if diameter > range
  end

  def hit enemy
    # TODO make something less adhoc
    return unless enemy.respond_to? :blocked?
    dx = (enemy.x - @player.x)/d(enemy, @player)**1.25 
    dy = (enemy.y - @player.y)/d(enemy, @player)**1.25 
    run = true
    @player.during(125) do 
      next unless run
      nx = enemy.x + range/10 * dx                            
      ny = enemy.y + range/10* dy                            
      if enemy.blocked?(nx,ny)
        run = false
        enemy.harm 5 # TODO animation?
        next
      end
      enemy.x = nx
      enemy.y = ny
    end
  end
end


Burst = Spell.new name: :blast, icon: 'droplet-splash.png' do |opts|
  player = opts[:player]
  wave = ShockWave.create x: player.x, y: player.y, player: player
end
