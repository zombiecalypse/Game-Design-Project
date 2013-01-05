require_relative '../object_traits/swarmer'
require_relative '../object_traits/mover'
require_relative '../object_traits/hp'
require_relative '../object_traits/aggro'
module Objects
  class Spider < Chingu::GameObject
    trait :aggro, damage: 1
    trait :mover
    trait :swarmer
    trait :hp, hp: 1
    trait :bounding_circle, debug: true

    def initialize(opts={})
      super(opts.merge image: Gosu::Image['spider.png'])
    end

    blocked_if do |x,y|
      parent.blocked? x,y
    end

    on_notice { |p| move_to p }
  end

end
