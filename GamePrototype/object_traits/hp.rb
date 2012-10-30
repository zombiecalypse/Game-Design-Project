require 'rubygems'
require 'chingu'
require 'gosu'

module Chingu::Traits
  module Hp
    module ClassMethods
      def initialize_trait(options)
        @hp_max = options[:hp] || 10
      end

      def hp_max
        @hp_max
      end

      alias_method :max_hp, :hp_max
    end

    attr_reader :hp

    def max_hp
      self.class.max_hp
    end

    def setup_trait(opts)
      @hp = (max_hp * ( opts[:hp_perc] || 1 ) ).to_i
      super opts
    end

    def harm dmg
      raise "Negative harm" if dmg < 0
      @hp -= dmg
      on_harm(dmg) if dmg != 0
      kill if @hp <= 0
    end

    def kill
      on_kill
      destroy
    end

    def heal hl
      raise "Negative heal" if hl < 0
      new_hp = [@hp + hl, max_hp].min
      d_hp = new_hp - @hp
      @hp = new_hp
      on_heal d_hp if d_hp != 0
    end

    def on_harm(dmg) ; end
    def on_heal(hl) ; end
    def on_kill ; end
  end
end
