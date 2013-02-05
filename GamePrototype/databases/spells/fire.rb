require_relative 'spell'
require_relative '../enemies'
require_relative '../../object_traits/attack'

class FireShot < Chingu::GameObject
  trait :bounding_circle, debug: true, scale: 0.5
  traits :velocity, :collision_detection, :timer

  trait :attack, enemies: Enemies::all, damage: 10, speed: 5, range: 500, destroy_on_hit: true

  def initialize(opts={})
    super opts
    @animation = Chingu::Animation.new file: 'fire_ani.png'
    @image = @animation.next
    self.center_y = 0.75
  end

  def update
    super
    @image = @animation.next if @animation
  end
  
  def update_trait
    super
    @parent.enter @x,@y
  end
  
  def random_directions
    @@degrees ||= (0..35).to_a.collect {|i| i*10}
    @@degrees.sample(15)
  end

  class ExplosionParticle < Chingu::Particle
    trait :timer
    def initialize(opts={})
      super({ 
        image: "fire_particle.png",
        scale_rate: +0.2,
        fade_rate: -10,
        rotation_rate: +9,
        mode: :default}.merge(opts))
      @dir = opts[:dir]
      @speed = opts[:speed]
    end

    def setup
      super
      after(500) {self.destroy}
    end

    def update
      super
      self.x += Math::cos(@dir)*@speed
      self.y += Math::sin(@dir)*@speed
    end
  end

  def on_destroy
    explode
  end

  def explode
    random_directions.each do |dir|
      ExplosionParticle.create(dir: dir, x: self.x, y: self.y, speed: Random.rand(15)+2)
    end
  end
end

Fire = Spell.new name: :fire, icon: 'cogsplosion.png', activation: true do |opts|
  FireShot.create(x: opts[:player].x, y: opts[:player].y, dir: opts[:phi])
end
