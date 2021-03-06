require 'rubygems'
require 'chingu'
require 'gosu'
require 'logger'
require 'modularity'
require_relative '../helpers/logging'
require_relative '../helpers/dist'

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
    include Helpers::DoesLogging

    def setup_trait(opts={})
      name = opts[:name]
      self.class.swarms[name] ||= []
      self.class.swarms[name] << self
      @swarm = self.class.swarms[name]
      log_debug {"Created new swarmer of #{name}"}
      super opts
    end

    def has_noticed?; @has_noticed; end

    def notify_swarm e
      @has_noticed = true # prevent infinite A-notifies-B-notifies-A loop
      @swarm.each do |x|
        x.notice e if x != self and not x.has_noticed? and d(self,x) <= observation_range
      end
      @has_noticed = nil
    end
  end
end
