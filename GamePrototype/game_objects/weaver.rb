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

      # An attack, that takes some time to lift the leg, but does devastating
      # damage.
      def pierce p
        @cooldown = true
        after(1000) do
          log_debug {"pierce at #{[p.x,p.y]}"}
        end.then do 
          after(1000) { @cooldown = nil }
        end
      end

      # An attack, that is somewhat quick and pushes the player away
      def slash p
        @cooldown = true
        log_debug {"slash at #{[p.x,p.y]}"}
        after(1000) do
          @cooldown = nil
        end
      end

      # An attack, that shoots an ball of immobilizing slime at the player
      def spit p
        log_debug {"spit at #{[p.x,p.y]}"}
        @cooldown = true
        after(1000) do
          @cooldown = nil
        end
      end

      # An fast attack, that deals little damage
      def stomp p
        log_debug {"stomp at #{[p.x,p.y]}"}
        @cooldown = true
        after(1000) do
          @cooldown = nil
        end
      end

      def piercing_distance; 200; end

      while_in(:playing_with_hero) do
        keep_distance the(Player), piercing_distance
        next if @cooldown
        d_to_player = d(self, the(Player))
        if d_to_player > piercing_distance*1.5
          spit the Player
        elsif d_to_player < piercing_distance*0.5
          stomp the Player
        else
          pierce the Player
        end
      end

      while_in :hiding do
        # move to save spot
        # become invincible
        # summon some enemies 
      end

      while_in :all_out do
        # become fast
        # slash or stomp
        # move toward player
      end
    end
  end
end
