require 'rubygems'
require 'chingu'
require 'gosu'
require_relative 'spells/fire'
require_relative 'spells/shield'
require_relative 'spells/burst'

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


  # Invariant: no spell can block another from being articulated by deleting the
  # buffer first.
  class SpellBook
    class << self
      attr_reader :depth, :dict
      def spell combination, s
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



      def lookup_spell combination
        postfixed = @dict.keys.detect {|key| combination.reverse.has_prefix? key.reverse }
        @dict[postfixed]
      end

      private
      def subsequence a, b
        return b if a.has_subsequence? b
        return a if b.has_subsequence? a
        nil
      end

    end

    def to_s
      d = self.class.dict
      d.keys\
        .collect {|k| "#{k}: #{d[k]}" }
        .join("\n")
    end

    def lookup combination
      self.class.lookup_spell combination
    end

    spell [:up, :right, :down, :left], Shield
    spell [:up, :down],  Fire
    spell [:left, :right, :down], Burst
  end
end
