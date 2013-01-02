require 'rubygems'
require 'chingu'
require 'gosu'

require_relative '../game_objects/simple_tower'

module Chingu::Traits
  module Spell
    module ClassMethods
      def initialize_trait(options)
        @spell_name = options[:name] 
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

    def spell_name
      self.class.spell_name
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
    trait :spell, name: :fire, size: [50,50], delay: 125
    traits :timer, :velocity, :collision_detection
    trait :bounding_circle, debug: true, scale: 0.5

    def initialize(opts={})
      super opts
      self.center_y = 0.75
    end
    def update
      super
      
      self.explode if @active and parent.blocked?(x,y)
      @image = @animation.next if @animation
      each_collision(Objects::SimpleTower) do |s, tower|
        s.explode_on tower
      end
    end

    def random_directions
      @@degrees ||= (0..35).to_a.collect {|i| i*10}
      @@degrees.sample(15)
    end

    class ExplosionParticle < Chingu::Particle
      trait :timer
      def initialize(opts={})
        super({ 
          image: "fire_particle.png",
          scale_rate: +0.2,
          fade_rate: -10,
          rotation_rate: +9,
          mode: :default}.merge(opts))
        @dir = opts[:dir]
        @speed = opts[:speed] || 5
      end

      def update
        super
        every(50) do
          self.x += Math::cos(@dir)*@speed
          self.y += Math::sin(@dir)*@speed
        end
        after(500) {self.destroy}
      end
    end

    def explode
      random_directions.each do |dir|
        ExplosionParticle.create(dir: dir, x: self.x, y: self.y, speed: Random.rand(5)+2)
      end
      self.destroy
    end

    def explode_on enemy
      enemy.harm 10
      explode
    end


    def run player
      player.spell = self
      @player = player
    end

    @@speed = 5

    def activate x,y
    	Gosu::Sample["fire_activate.ogg"].play
      @player.spell = nil
      @active = true
      self.x = @player.x
      self.y = @player.y
      dx, dy = x-@player.x_window, y-@player.y_window
      phi = Math::atan2(dy,dx)
      self.velocity = [@@speed * Math::cos(phi), @@speed * Math::sin(phi)]
      after(1000) { self.destroy }
    end
  end

  class Shield < Chingu::GameObject
    trait :spell, name: :shield
    trait :timer

    def run player
      self.x, self.y = player.x, player.y
      player.vulnerability = 0.2
      during(2000) do
        self.x, self.y = player.x, player.y
        self.alpha *= 0.99
      end.then do
        player.vulnerability = 1
        self.destroy 
      end
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
