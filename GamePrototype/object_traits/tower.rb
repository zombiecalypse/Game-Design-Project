require 'rubygems'
require 'chingu'
require 'gosu'

module Chingu::Traits
  module Tower
    module ClassMethods
      # A projectile producer (answers to `call`) can be given.
      def initialize_trait(options={})
        @projectile = options[:projectile] || (Proc.new { Projectile.new })
      end
    end
    class Projectile < Chingu::GameObject
      trait :bounding_circle
      trait :collision_detection
      trait :velocity

      def on_hit player
        player.harm 10
      end

      def update
        super
        each_collision(Objects::Player) do |s, player|
          on_hit(player)
        end
      end
    end
  end
end
