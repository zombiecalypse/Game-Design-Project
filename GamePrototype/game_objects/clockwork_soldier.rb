module Objects
  module Clockwork
    class Soldier < Chingu::GameObject
      trait :shooter
      trait :aggro, damage: 0, range: 400
      trait :mover
      trait :hp, hp: 20
      trait :bounding_box
      trait :state_ai, start: :exploration
      trait :timer

      def speed; 2; end

      def initialize(opts={})
        super(opts.merge image: Gosu::Image[DummyImage])
      end

      on_notice do |p|
        if state == :exploration
          self.state = :ranged 
          @enemy = p
        end
      end

      on_attack do |p|
        if state == :ranged
          shoot p
        elsif state == :melee
          hack p
        end
      end

      def hack p
        p.harm 10
      end

      blocked_if do |x,y|
        parent.blocked? x,y
      end

      while_in(:exploration) do
      end

      while_in(:ranged) do
        self.state = :melee if d(self, @enemy) < 100
        keep_distance @enemy, 300
      end

      while_in(:melee) do
        self.state = :melee if d(self, @enemy) > 200
        keep_distance @enemy, 50
      end

      def aggressive?; [:ranged, :melee].include? state ; end
    end
  end
end
