require 'rubygems'
require 'chingu'
require 'gosu'

module Chingu::Traits
  module Spell
    module ClassMethods
      def initialize_trait(options)
        @spell_name = options[:name] || "<no name>"
        super
      end
      def spell_name
        @spell_name
      end
    end

    def setup_trait(options)
      @image ||= Gosu::Image["#{self.class.spell_name}.png"]
      super
    end
  end
end                 

class Array
  def has_prefix? b
    return false unless length >= b.length
    self.zip(b).all? {|x,y| x == y or y.nil?}
  end

  def has_subsequence? b
    self.each_index do |i|
      return true if self.drop(i).has_prefix? b
    end
    return false
  end
end


module Databases
  class Fire < Chingu::GameObject
    trait :spell, name: :fire
    trait :timer

    def run player
      self.center_y = 0
      during(1000) do
        self.x, self.y = player.x, player.y
        self.alpha *= 0.9
      end.then { self.destroy }
    end
  end
  class Shield < Chingu::GameObject
    trait :spell, name: :shield
    trait :timer

    def run player
      self.x, self.y = player.x, player.y
      during(2000) do
        self.x, self.y = player.x, player.y
        self.alpha *= 0.99
      end.then { self.destroy }
    end
  end


  # Invariant: no spell can block another from being articulated by deleting the
  # buffer first.
  class SpellBook
    class << self
      attr_reader :depth
      def spell s, combination
        @dict  ||= {}
        @depth ||= 0
        conflicts = @dict.keys \
            .collect {|c| c if subsequence(c, combination)} \
            .select {|c| not c.nil?} \
            .collect {|c| [@dict[c],c]}
        raise "Common subsequence: #{conflicts} vs. #{combination} in #{@dict}" unless conflicts == []
        @dict[combination] = s
        @depth = [combination.length, @depth].max
      end

      def lookup_spell c
        @dict[c]
      end

      private
      def subsequence a, b
        return b if a.has_subsequence? b
        return a if b.has_subsequence? a
        nil
      end

    end

    def lookup combination
      self.class.lookup_spell combination
    end

    spell Shield, [:top_arc] 
    spell Fire, [:up, :down]
  end
end
