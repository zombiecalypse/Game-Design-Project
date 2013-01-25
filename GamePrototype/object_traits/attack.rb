module Chingu::Traits
  # An attack animation, that triggers some kind of effect, when an enemy (or
  # conversely the player) is caught in it.
  #
  # options:
  #   class:
  #     enemies:         List of classes to be affected by this attack
  #     damage:          Number of HP damage, the victim takes
  #     destroy_on_hit:  Destroy animation after the first update, where any
  #                      enemy is hit.
  #     speed:           speed (in pixel), with which to move (optional)
  #     range:           maximal number of pixel that the attack moves, before it
  #                      destroys itself
  #   instance: 
  #     dir:             direction (in arc), in which to move (optional)
  #
  # requires:
  #   :bounding_{box,circle}
  #   :collision_detection
  #   :velocity
  module Attack
    module ClassMethods
      def initialize_trait(opts={})
       trait_options[:attack] = opts 
       trait_options[:enemies] ||= [opts[:enemy]]
      end
    end

    def setup_trait(opts={})
      super opts
      @has_hit = []
      @moved = 0
      @dir = opts[:dir]
    end

    def update_trait
      super
      moves
      hits
    end

    def moves
      dir = @dir
      speed = trait_options[:attack][:speed]
      range = trait_options[:attack][:range]
      return unless dir
      return unless speed
      self.x += Math::cos(dir) * speed
      self.y += Math::sin(dir) * speed
      @moved += speed
      self.destroy if range and @moved > range
    end

    def hits
      each_collision(*trait_options[:attack][:enemies]) do |s, enemy|
        unless @has_hit.include? enemy
          hit enemy
          @has_hit << enemy
        end
      end
      return unless trait_options[:attack][:destroy_on_hit]
      return self.destroy unless @has_hit.empty?
      return self.destroy if parent.blocked?(x,y)
    end

    def destroy
      on_destroy
      super
    end

    def on_destroy; end

    def hit enemy
      enemy.harm trait_options[:attack][:damage]
    end
  end
end
