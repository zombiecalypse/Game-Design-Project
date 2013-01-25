module Objects
  module Boss
    # A giant spider, that attacks in 3 phases:
    #   > Playing with hero
    #   > Playing with hero
    #   > All out
    class Weaver < Chingu::GameObject
      does 'helpers/logging', level: Logger::DEBUG
      trait :mover, speed: 3
      trait :hp, hp: 400
      trait :state_ai, start: :playing_with_hero
      trait :bounding_box
      trait :timer
      trait :asynchronous

      def initialize(opts={})
        @animation = Chingu::Animation.new file: 'weaver.png', size: 192, delay: 250
        @animation.frame_names = { 
          down: 0..3,
          left: 4..7,
          right: 8..11,
          up: 12..15
        }
        @current_animation = @animation[:down]
        super(opts.merge image: @current_animation.next)
      end

      def cooldown_time
        return 1000 if state == :all_out

        2000
      end

      # An attack, that takes some time to lift the leg, but does devastating
      # damage.
      def pierce p
        @cooldown = true
        after(1000) do
          log_debug {"pierce at #{[p.x,p.y]}"}
        end.then do 
          after(cooldown_time) { @cooldown = nil }
        end
      end

      # An attack, that is somewhat quick and pushes the player away
      def slash p
        @cooldown = true
        log_debug {"slash at #{[p.x,p.y]}"}
        after(cooldown_time) do
          @cooldown = nil
        end
      end

      # An attack, that shoots an ball of immobilizing slime at the player
      def spit p
        @cooldown = true
        log_debug {"spit at #{[p.x,p.y]}"}
        after(cooldown_time) do
          @cooldown = nil
        end
      end

      # An fast attack, that deals little damage
      def stomp p
        log_debug {"stomp at #{[p.x,p.y]}"}
        @cooldown = true
        after(cooldown_time) do
          @cooldown = nil
        end
      end

      def piercing_distance; 200; end

      def on_harm x
        if hp < 100 and state == :second_playing_with_hero
          log_debug {"Go hiding second time"}
          self.state = :hiding 
          after(20000) {self.state = :all_out}
        elsif hp < 250 and state == :playing_with_hero
          log_debug {"Go hiding first time"}
          self.state = :hiding 
          after(20000) {self.state = :second_playing_with_hero}
        end
      end

      def harm x
        super x unless state == :hiding
      end

      def playing_with_hero
        keep_distance the(Player), piercing_distance
        return if @cooldown
        d_to_player = d(self, the(Player))
        if d_to_player > piercing_distance*1.5
          spit the Player
        elsif d_to_player < piercing_distance*0.5
          stomp the Player
        else
          pierce the Player
        end
      end

      def summon_spiders
        log_debug {"Summoning new spiders"}
      end

      while_in(:playing_with_hero) { playing_with_hero }

      while_in(:second_playing_with_hero) { playing_with_hero }

      while_in :hiding do
        # move to save spot
        # become invincible
        # summon some enemies 
        move_away_from the Player
        every(3000) do
          summon_spiders
        end
      end

      while_in :all_out do
        # become fast
        @speed = 5
        # move toward player
        d_to_player = d(self, the(Player))
        keep_distance the(Player), piercing_distance*0.75
        next unless d_to_player < piercing_distance*1.5

        # slash or stomp
        if rand < 0.25
          stomp the Player
        else
          slash the Player
        end
      end
    end
  end
end
