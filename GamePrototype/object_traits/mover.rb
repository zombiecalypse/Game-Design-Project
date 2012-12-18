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

    attr_reader :speed

    def enemies
      @enemies.inject([]) { |x,y| x+y.all }
    end

    def setup_trait(opts={})
      @speed = trait_options[:mover][:speed] || 2000
    end


    def move
      if @goal.position != @old_goal_position
        @path = recalculate_path_to @goal
        @old_goal_position = @goal.position
      end

      move_along_path
    end

    # fill AI here, seriously... do!
    def recalculate_path_to; end

    def move_along_path
      first = @path[0]
      return if not first
      if d(self, first) < speed # wont loop but assumes 
        @path = @path[1..-1]    # well-behaved suroundings
        move_along_path
      else
        phi = Math.atan2(first.y - y, first.x - x) # Directly at point
        x += Math.cos(phi) * speed
        y += Math.sin(phi) * speed
      end
    end

    def update_trait
      super
      move
    end

    private
    def log_debug(&b)
      self.class.log_debug(&b)
    end
  end
end
