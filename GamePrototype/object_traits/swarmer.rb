require 'rubygems'
require 'chingu'
require 'gosu'
require 'logger'
require 'modularity'
require_relative '../helpers/logging'

module Chingu::Traits
  module Swarmer
    module ClassMethods
      # :swarm_dist: how far away other members of the swarm can be located as
      #              to be notified if an enemy appears
      def initialize_trait(options={})
        @swarms = {}
        trait_options[:swarmer] = options

        self.on_notice do |e|
          notify_swarm e
        end
      end

      attr_reader :swarms
    end
    include Modularity::Does
    does "helpers/logging"

    def setup_trait(opts={})
      name = opts[:name]
      self.class.swarms[name] ||= []
      self.class.swarms[name] << self
      @swarm = self.class.swarms[name]
      log_debug {"Created new swarmer of #{name}"}
      super opts
    end

    def notify_swarm e
      @swarm.each do |x|
        x.notice e if x != self and d(self,x) <= observation_range
      end
    end
  end
end
