require_relative '../object_traits/hp'
require_relative '../object_traits/shooter'
require_relative '../object_traits/aggro'

module Objects
  class SimpleTower < Chingu::GameObject
    class Projectile < Chingu::Traits::Shooter::Projectile
      trait :timer

      def timeout
        2000
      end

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

    trait :shooter, projectile: Projectile
    trait :aggro, damage: 0, observation_range: 300, range: 300
    trait :bounding_box, debug: true
    trait :hp, hp: 50

    def initialize(opts={})
      super(opts.merge image: Gosu::Image['spider_tower.png'])
      self.center_y = 0.25
    end

    on_attack do |p|
      shoot p.x, p.y
    end
  end
end
