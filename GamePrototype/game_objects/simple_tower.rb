require_relative '../object_traits/hp'
require_relative '../object_traits/tower'


module Objects
  class SimpleTower < Chingu::GameObject
    class Projectile < Chingu::Traits::Tower::Projectile
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

    trait :tower, projectile: Projectile
    trait :timer
    trait :bounding_box, debug: true
    trait :hp, hp: 50

    def initialize(opts={})
      super(opts.merge image: Gosu::Image['tower.png'])
      every(1500, name: :shoot) do
        shoot(Player.the.x, Player.the.y)
      end
    end
  end
end
