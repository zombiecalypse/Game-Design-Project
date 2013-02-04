require_relative '../object_traits/swarmer'
require_relative '../object_traits/mover'
require_relative '../object_traits/hp'
require_relative '../object_traits/aggro'
module Objects
  class Spider < Chingu::GameObject
    include Modularity::Does
    does 'helpers/logging'
    trait :aggro, damage: 1
    trait :mover
    trait :hp, hp: 5
    trait :bounding_circle
    trait :asynchronous

    def initialize(opts={})
      super(opts.merge image: Gosu::Image['spider.png'])
    end

    blocked_if do |x,y|
      parent.blocked? x,y
    end

    on_notice { |p| move_to p }
  end

end
