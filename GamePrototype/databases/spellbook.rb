require 'rubygems'
require 'chingu'
require 'gosu'

module Chingu::Traits
  module Spell
    module ClassMethods
      def initialize_trait(options)
        @spell_name = options[:name] || "<no name>"
        @options = options
        super
      end
      def spell_name
        @spell_name
      end

      def options
        @options
      end
    end

    def setup_trait(options)
      opts = {file: "#{self.class.spell_name}_ani.png"}.merge(self.class.options)
      @animation = Chingu::Animation.new( opts ) rescue nil
      if @animation
        @image = @animation.next
      else
        @image ||= Gosu::Image["#{self.class.spell_name}.png"]
      end
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
    trait :spell, name: :fire, size: [200,400], delay: 125
    traits :timer, :velocity

    def update
      super
      @image = @animation.next if @animation
    end

    @@dir_to_vector = {
      left:  [-5,0],
      right: [ 5,0],
      up:    [0,-5],
      down:  [0, 5]
    }


    def run player
      self.center_y = 0.75
      self.x = player.x
      self.y = player.y
      self.velocity = @@dir_to_vector[player.current_dir]
      after(1000) { self.destroy }
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
      attr_reader :depth, :dict
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

    spell Shield, [:top_arc] 
    spell Fire, [:up, :down]
  end
end
