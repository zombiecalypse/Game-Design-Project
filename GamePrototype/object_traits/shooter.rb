
module Chingu::Traits
  module Shooter
    module ClassMethods
      def initialize_trait(opts={})
        @projectile = opts[:projectile] || Projectile
        trait_options[:shooter] = opts
        @log = Logger.new(STDOUT)
      end

      def log_debug(&b)
        @log.debug(self.to_s, &b)
      end

      attr_reader :projectile
    end

    def log_debug(&b)
      self.class.log_debug(&b)
    end

    def shoot x,y
      log_debug {"Shooting at #{[x,y]}"}
      dx, dy = x - self.x, y - self.y
      proj = produce_projectile x: self.x, y: self.y, at_x: dx, at_y: dy
      proj.on_shoot
      log_debug {"Proj: #{proj} => #{proj.velocity}"}
    end

    def produce_projectile(opts={})
      self.class.projectile.call(opts) rescue self.class.projectile.create(opts)
    end

    class Projectile < Chingu::GameObject
      trait :bounding_circle
      trait :collision_detection
      trait :velocity

      def initialize opts={}
        super({:image => Gosu::Image['projectile.png']}.merge(opts))
        phi = Math::atan2 opts[:at_y], opts[:at_x]
        self.velocity_x = Math::cos(phi) * self.max_speed
        self.velocity_y = Math::sin(phi) * self.max_speed
      end

      def max_speed 
        5
      end

      def on_hit player
        player.harm 10
      end

      def update
        super
        each_collision(Objects::Player) do |s, player|
          on_hit(player)
          self.destroy
        end
      end

      def on_shoot
      end
    end
  end
end
