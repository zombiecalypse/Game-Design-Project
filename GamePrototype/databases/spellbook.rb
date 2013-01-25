require 'rubygems'
require 'chingu'
require 'gosu'
require 'modularity'

require_relative '../databases/enemies'
require_relative '../object_traits/attack'

class Spell
  attr_reader :name
  # Options:
  #   name: Used for display
  #   activation: Is the spell held back until the player clicks somewhere?
  #   icon: Is displayed when the gesture is complete to inform the player
  #   sound: The sound played on activation (if it is used) or running
  #
  # block: is executed on activation (if used) or running with the following
  #        parameters:
  #   x,y: the point, where the player clicked if activation
  #   dx, dy: difference to the player coordinates
  #   phi: the angle in which the player clicked
  #   player: the player object
  def initialize opts={}, &block
    @name = opts[:name]
    @activation = opts[:activation]
    @icon = opts[:icon]
    @sound = opts[:sound]
    @block = block
    invariant
  end

  def invariant
    raise "No name" unless @name
    raise "No icon" unless @icon
    raise "No block" unless @block
  end

  def run player
    the(Interface::HudInterface).spell_notification(@icon)
    if @activation
      player.spell = self
      @player = player
    else
      @sound.play if @sound
      @block.call player: player
    end
  end

  def activate x,y
    @sound.play if @sound
    @player.spell = nil
    dx = x - @player.x_window
    dy = y - @player.y_window
    phi = Math::atan2(dy,dx)
    @block.call player: @player, 
      x: x, y: y, 
      dx: dx, dy: dy,
      phi: phi
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
  class FireShot < Chingu::GameObject
    trait :bounding_circle, debug: true, scale: 0.5
    traits :velocity, :collision_detection, :timer

    trait :attack, enemies: Enemies::all, damage: 10, speed: 5, range: 500, destroy_on_hit: true

    def initialize(opts={})
      super opts
      @animation = Chingu::Animation.new file: 'fire_ani.png'
      @image = @animation.next
      self.center_y = 0.75
    end

    def update
      super
      @image = @animation.next if @animation
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
        @speed = opts[:speed]
      end

      def setup
        super
        after(500) {self.destroy}
      end

      def update
        super
        self.x += Math::cos(@dir)*@speed
        self.y += Math::sin(@dir)*@speed
      end
    end

    def on_destroy
      explode
    end

    def explode
      random_directions.each do |dir|
        ExplosionParticle.create(dir: dir, x: self.x, y: self.y, speed: Random.rand(15)+2)
      end
    end
  end

  Fire = Spell.new name: :fire, icon: 'cogsplosion.png', activation: true do |opts|
    FireShot.create(x: opts[:player].x, y: opts[:player].y, dir: opts[:phi])
  end

  Shield = Spell.new name: :shield, icon: 'bolt-shield.png' do |opts|
    player = opts[:player]
    player.vulnerability = 0.2
    player.color = Colors::SHIELD
    player.during(2000) do
      player.color.alpha *= 0.99
    end.then do
      player.color = nil
      player.vulnerability = 1
    end
  end


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

    spell [:up, :right], Shield
    spell [:up, :down], Fire
  end
end
