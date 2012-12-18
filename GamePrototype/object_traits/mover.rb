require 'logger'

module Chingu::Traits
  # Type of enemy that moves towart the player and hits them.
  module Mover
    module ClassMethods
      def initialize_trait(options={})
        @log = Logger.new(STDOUT)
        @log.sev_threshold = Logger::INFO
        @on_notice = []
        @on_attack = []
        trait_options[:mover] = options
      end

      def log_debug(&b)
        @log.debug(self.to_s, &b)
      end

      def on_notice &b
        @on_notice << b
      end

      def on_attack &b
        @on_attack << b
      end
    end

    attr_reader :observation_range, :enemies, :speed

    def setup_trait(opts={})
      @enemies = trait_options[:mover][:enemies] || []
      @enemies << Player if not @enemies.include? Player 
      @damage = trait_options[:swarmer][:damage]
      @observation_range = trait_options[:swarmer][:range] || 200
      @attack_cooldown = trait_options[:mover][:attack_cooldown] || 2000
      @speed = trait_options[:mover][:speed] || 2000
    end


    def move
      if @goal.position != @old_goal_position
        @path = recalculate_path_to @goal
        @old_goal_position = @goal.position
      end

      move_along_path
    end

    # fill AI here
    def recalculate_path_to; end

    trait :bounding_circle
    trait :collision_detection
    trait :timer

    def move_along_path
      first = @path[0]
      return if not first
      if d(self, first) < speed # wont loop but assumes 
        @path = @path[1..-1]    # well-behaved suroundings
        move_along_path
      else
        phi = Math.atan2(first.y - y, first.x - x)
        x += Math.cos(phi) * speed
        y += Math.sin(phi) * speed
      end
    end

    def update_trait
      super
      move
      look_around
      every(@attack_cooldown) { attack_reachable }
    end

    def attack e
      on_attack e
      e.harm @damage
    end

    private

    def attack_reachable
      each_collision(enemies) do |s, enemy|
        attack enemy
        log_debug {"#{self} attacks #{enemy}"}
        return
      end
    end


    def look_around
      enemies.each do |enemy|
        if d(enemy, self) <= observation_range
          do_on_notice enemy 
          log_debug {"#{self} found #{enemy}"}
        end
      end
    end

    def do_on_notice e
      @@on_notice.each {|b| b.call e}
    end

    def do_on_attack e
      @@on_attack.each {|b| b.call e}
    end

    def d a, b
      Math.hypot (a.x - b.x), (a.y - b.y)
    end

    def log_debug(&b)
      self.class.log_debug(&b)
    end
  end
end
