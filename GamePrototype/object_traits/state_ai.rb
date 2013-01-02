require 'rubygems'
require 'chingu'
require 'gosu'
require 'logger'
require 'modularity'
require_relative '../helpers/logging'

module Chingu::Traits
  module StateAi
    include Modularity::Does
    does "helpers/logging"

    module ClassMethods
      def initialize_trait(opts={})
        trait_options[:state_ai] = opts
        @states = {}
      end

      def when_in(sym, &block)
        @states[sym] = block
      end
      attr_reader :states
    end

    def setup_trait(opts={})
      super opts
      @state = :start
    end

    attr_reader :state

    def state= new_state
      return if new_state == state
      log_debug { "Switching from #{state} to #{new_state}" }
      @state = new_state
    end

    def update_trait
      super
      block = self.class.states[state]
      self.instance_exec(&block) if block
    end
  end
end
