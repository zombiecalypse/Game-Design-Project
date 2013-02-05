require_relative 'player'
require_relative '../object_traits/attack'
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

      blocked_if do |x,y|
        parent.blocked? x,y
      end

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

      def need_cooldown
        @cooldown = true
        after(cooldown_time) do
          @cooldown = nil
        end
      end

      def angle_to p
        dx = p.x - x
        dy = p.y - y
        Math::atan2(dy, dx)
      end

      def on_kill
        $window.switch_game_state(Levels::End)
      end

      # An attack, that takes some time to lift the leg, but does devastating
      # damage.
      def pierce p
        @cooldown = true
        pierce = Pierce.create(x: x, y: y, dir: angle_to(p))
        after(1000) do
          pierce.speed = 15
          log_debug {"pierce at #{[p.x,p.y]}"}
        end.then do 
          after(cooldown_time) { @cooldown = nil }
        end
      end

      # An attack, that is somewhat quick and pushes the player away
      def slash p
        slash = Slash.create(x: x, y: y, dir: angle_to(p))
        log_debug {"slash at #{[p.x,p.y]}"}
        need_cooldown
      end


      # An attack, that shoots an ball of immobilizing slime at the player
      def spit p
        spit = Spit.create(x: x, y: y, dir: angle_to(p))
        need_cooldown
      end

      # An fast attack, that deals little damage
      def stomp p
        @cooldown = true
        stomp = Stomp.create(x: x, y: y, dir: angle_to(p))
        log_debug {"stomp at #{[p.x,p.y]}"}
        after(750) do 
          @cooldown = false
        end
      end

      def piercing_distance; 200; end

      def on_harm x
        if hp < 100 and state == :second_playing_with_hero
          log_debug {"Go hiding second time"}
          self.state = :hiding 
          after(3000) { summon_spiders }\
            .then { after(10000) { summon_spiders }}
          after(20000) {self.state = :all_out}
        elsif hp < 250 and state == :playing_with_hero
          log_debug {"Go hiding first time"}
          self.state = :hiding 
          after(3000) { summon_spiders }\
            .then { after(10000) { summon_spiders }}
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
        (1..5).each { parent.create_spider }
      end

      blocked_if do |x,y|
        parent.blocked? x,y
      end

      def hide
        # move to save spot
        # become invincible
        # summon some enemies 
        move_away_from the Player
      end

      def all_out
        # become fast
        @speed = 5
        # move toward player
        return if @cooldown
        d_to_player = d(self, the(Player))
        keep_distance the(Player), piercing_distance*0.75
        return unless d_to_player < piercing_distance*1.5

        # slash or stomp
        if rand < 0.25
          stomp the Player
        else
          slash the Player
        end
      end


      while_in(:playing_with_hero) { playing_with_hero }

      while_in(:second_playing_with_hero) { playing_with_hero }

      while_in(:hiding) { hide }

      while_in(:all_out) { all_out }

      class Spit < Chingu::GameObject
        trait :bounding_circle
        traits :velocity, :collision_detection

        trait :attack, damage: 10, speed: 5, range: 800, destroy_on_hit: true

        def initialize(opts={})
          super({image: 'projectile.png'}.merge! opts)
        end
      end

      class Pierce < Chingu::GameObject
        trait :bounding_circle
        traits :velocity, :collision_detection

        trait :attack, damage: 10, speed: 2, range: 300

        attr_accessor :speed

        def initialize(opts={})
          super({image: 'projectile.png'}.merge! opts)
        end
      end
      
      class Stomp < Chingu::GameObject
        trait :bounding_circle
        traits :velocity, :collision_detection

        trait :attack, damage: 3, speed: 20, range: 250

        def initialize(opts={})
          super({image: 'projectile.png'}.merge! opts)
        end
      end

      class Slash < Chingu::GameObject
        trait :bounding_circle
        traits :velocity, :collision_detection

        trait :attack, damage: 3, speed: 15, range: 250

        def initialize(opts={})
          super({image: 'projectile.png'}.merge! opts)
        end

        def hit player
          dx = (player.x - self.x)/d(player, self)
          dy = (player.y - self.y)/d(player, self)
          player.during(250) do
            nx = player.x + 5*dx
            ny = player.y + 5*dy
            next if parent.blocked?(nx,ny)
            player.x = nx
            player.y = ny
          end
        end
      end
    end
  end
end
