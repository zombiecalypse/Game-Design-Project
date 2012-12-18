module Chingu::Traits
  # Type of enemy that just shoots as soon as possible
  module Aggro
    module ClassMethods
      def initialize_trait(options={})
        @log = Logger.new(STDOUT)
        @log.sev_threshold = Logger::INFO
        @on_notice = []
        @on_attack = []
        trait_options[:aggro] = options
        self.trait :timer
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

    attr_reader :observation_range

    def enemies
      @enemies.inject([]) { |x,y| x+y.all }
    end

    def setup_trait(opts={})
      @enemies           = trait_options[:aggro][:enemies]         || []
      @damage            = trait_options[:aggro][:damage]          || 1
      @observation_range = trait_options[:aggro][:range]           || 200
      @attack_cooldown   = trait_options[:aggro][:attack_cooldown] || 2000
      @range             = trait_options[:aggro][:range]           || 50

      @enemies << the(Player) if not @enemies.include? the(Player)
      @can_attack = true
    end

    def update_trait
      super
      attack_reachable if @can_attack
    end


    private

    def attack_reachable
      enemy = enemies.detect {|e| can_attack? e}
      return unless enemy
      attack enemy
      log_debug {"#{self} attacks #{enemy}"}
    end

    def noticable? enemy
      d(enemy, self) <= observation_range
    end

    def look_around
      enemies
        .collect {|e| noticable? e}
        .each do |enemy|
          do_on_notice enemy 
          log_debug {"#{self} found #{enemy}"}
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

    def attack e
      do_on_attack e
      e.harm @damage
      @can_attack = false
      after(@attack_cooldown) { @can_attack = true }
    end

    def can_attack? enemy
      d(enemy, self) < @reach
    end

    def log_debug(&b)
      self.class.log_debug(&b)
    end

  end
end
