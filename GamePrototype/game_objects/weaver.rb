module Objects
  module Boss
    # A giant spider, that attacks in 3 phases:
    #   > Playing with hero
    #   > Playing with hero
    #   > All out
    class Weaver < Chingu::GameObject
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
      end

      # An attack, that is somewhat quick and pushes the player away
      def slash p
      end

      # An attack, that shoots an ball of immobilizing slime at the player
      def spit p
      end

      # An fast attack, that deals little damage
      def stomp p
      end

      while_in(:playing_with_hero) do
        move_to the Player
        # pierce middle distance
        # slash close distance
        # spit long distance
        # move into piercing distance
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
