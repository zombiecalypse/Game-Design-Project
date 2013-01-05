require_relative '../object_traits/mover'
require_relative '../object_traits/hp'
require_relative '../object_traits/shooter'
require_relative '../object_traits/aggro'
require_relative '../object_traits/state_ai'
require_relative '../helpers/dummy_image'

module Objects
  class Sniper < Chingu::GameObject
    class Projectile < Chingu::Traits::Shooter::Projectile
      trait :timer

      def max_speed; 10; end

      def timeout; 2000; end

      def setup
        super
        after(timeout) { self.destroy }
        every(50) do
          self.angle += 10 
        end
      end

      def on_hit player
        player.harm 10
      end
    end
    include Modularity::Does
    does 'helpers/logging'

    trait :shooter, projectile: Projectile
    trait :aggro, damage: 0, range: 400
    trait :mover
    trait :hp, hp: 20
    trait :bounding_box, debug: true
    trait :state_ai, start: :exploration
    trait :timer

    def speed; 2; end

    def initialize(opts={})
      super(opts.merge image: Gosu::Image[DummyImage])
    end

    on_notice do |p|
      if state == :exploration
        self.state = :attacking 
        @enemy = p
      end
    end

    blocked_if do |x,y|
      parent.blocked? x,y
    end

    while_in(:exploration) do
    end

    while_in(:attacking) do
      self.state = :panic if d(self, @enemy) < 100
      keep_distance @enemy, 300
    end

    def aggressive?; state == :attacking; end

    while_in(:panic) do
      during(1500) do
        move_away_from @enemy
      end.then do
        self.state = :attacking
      end
    end
  end
end
