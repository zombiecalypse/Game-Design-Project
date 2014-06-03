require_relative '../helpers/logging'
require_relative '../helpers/dist'

module Chingu::Traits
  # Type of enemy that just shoots as soon as possible
  module Aggro
    include Helpers::DoesLogging
    module ClassMethods
      attr_reader :all_on_notice, :all_on_attack
      def initialize_trait(options={})
        @all_on_notice = []
        @all_on_attack = []
        trait_options[:aggro] = options
        self.trait :timer
      end

      def on_notice &b
        @all_on_notice << b
      end

      def on_attack &b
        @all_on_attack << b
      end
    end

    attr_reader :observation_range

    def enemies
      @enemies.inject([]) { |x,y| x+y.all }
    end

    def setup_trait(opts={})
      @enemies           = trait_options[:aggro][:enemies]            || []
      @damage            = trait_options[:aggro][:damage]             || 1
      @observation_range = trait_options[:aggro][:observation_range]  || 200
      @attack_cooldown   = trait_options[:aggro][:attack_cooldown]    || 2000
      @range             = trait_options[:aggro][:range]              || 50

      @enemies << Objects::Player if not @enemies.include? Objects::Player
      @can_attack = true
      super opts
    end

    def update_trait
      super
      look_around
      attack_reachable if @can_attack and aggressive?
    end

    def aggressive?; true; end


    def cooldown!
      @can_attack = true
    end

    def notice p
      do_on_notice p
    end

    private

    def attack_reachable
      log_debug {"I'm looking for enemies"}
      enemy = enemies.detect {|e| can_attack? e}
      return unless enemy
      log_debug {"I found #{enemy}"}
      attack enemy
    end

    def noticable? enemy
      d(enemy, self) <= observation_range
    end

    def look_around
      enemies
        .select {|e| noticable? e}
        .each do |enemy|
          do_on_notice enemy 
          log_debug {"I found #{enemy}"}
        end
    end

    def do_on_notice e
      self.class.all_on_notice.each {|b| self.instance_exec(e,&b)}
    end

    def do_on_attack e
      self.class.all_on_attack.each {|b| self.instance_exec(e,&b)}
    end

    def attack e
      do_on_attack e
      log_debug {"I attack #{e} for #{@damage} damage"}
      e.harm @damage
      @can_attack = false
      after(@attack_cooldown) { cooldown! }
    end

    def can_attack? enemy
      d(enemy, self) < @range rescue false
    end
  end
end
