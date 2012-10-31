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

      def on_shoot
        puts "Pew!"
      end

      def on_hit player
        puts "blarg!"
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
        if $window.current_game_state.respond_to? :player
          player_coords = [$window.current_game_state.player.x,$window.current_game_state.player.y]
          shoot(*player_coords)
        else
          shoot(500,500)
        end
      end
    end
  end
end
