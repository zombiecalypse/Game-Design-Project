require 'rubygems'
require 'chingu'
require 'gosu'
require 'logger'

module Chingu::Traits
  module Swarmer
    module ClassMethods
      # :swarm_dist: how far away other members of the swarm can be located as
      #              to be notified if an enemy appears
      def initialize_trait(options={})
        @log = Logger.new(STDOUT)
        @log.sev_threshold = Logger::INFO
        @swarms = {}
        trait_options[:swarmer] = options

        self.on_notify do |e|
          notify_swarm e
        end
      end

      def log_debug(&b)
        @log.debug(self.to_s, &b)
      end
    end

    def setup_trait(opts={})
      name = opts[:name]
      @@swarms[name] ||= []
      @@swarms[name] << self
      @swarm = @@swarms[name]
      log_debug {"Created new swarmer of #{name}"}
      super opts
    end

    def notify_swarm e
      @swarm.each do |x|
        x.on_notice e if d(self,x) <= observation_range
      end
    end
  end
end
