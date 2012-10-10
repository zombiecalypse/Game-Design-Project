require 'rubygems'
require 'chingu'
require 'gosu'

module Databases
  class Spell
    attr_reader :name
    def initialize name, block
      @name = name
      @block = block
    end

    def to_s
      @name.to_s
    end

    def run player
      if @block
        @image ||= Gosu::Image["#{@name}.png"]
        sprite = SpellSprite.create(:image =>  @image)
        sprite.instance_exec(player, &@block)
      else
        puts @name
      end
    end
  end

class SpellSprite < Chingu::GameObject
  traits :timer
  def initialize(options = {})
    super(options)
  end
end

  # Invariant: no spell can block another from being articulated by deleting the
  # buffer first.
  class SpellBook
    class << self
      attr_reader :depth
      def spell name, combination, &block
        @root  ||= {}
        @depth ||= 0
        insert Spell.new(name, block), combination.reverse, @root
        @depth = [combination.length, @depth].max
      end

      def lookup_spell combination
        lookup combination.reverse, @root
      end

      private
      def insert item, word, map
        raise "empty combination" if word.size == 0
        nxt, rest = word.first, word.drop(1)
        if rest.size == 0 
          raise "#{item} and #{map[nxt]} have similar combination!" if map[nxt]
          map[nxt] = item
        elsif map[nxt].nil?
          map[nxt] = insert(item, rest, {})
        else
          raise "#{item} has combination of #{map[nxt]} as postfix" unless map[nxt].kind_of? Hash
          insert(item, rest, map[nxt])
        end
        map
      end

      def lookup combination, tree
        return nil unless tree
        return nil if combination.size == 0
        return tree if not tree.kind_of? Hash
        first, rest = combination.first, combination.drop(1)
        return lookup rest, tree[first]
      end
    end

    def lookup combination
      self.class.lookup_spell combination
    end

    spell :shield, [:top_arc] do |player|
      color.alpha = 128
      during(1000) do 
        color.alpha *= 0.99
        self.x = player.x
        self.y = player.y
      end.then { self.destroy }
    end
    spell :fire, [:up, :down] do |player|
      self.center_y = 0
      self.scale = 0.25
      during(500) do
        color.alpha *= 0.98
        self.x= player.x
        self.y= player.y
      end.then { self.destroy }
    end
    spell :fire_boom, [:up, :up, :up]
  end
end
