require_relative '../object_traits/swarmer'
require_relative '../object_traits/mover'
require_relative '../object_traits/hp'
require_relative '../object_traits/shooter'
require_relative '../object_traits/aggro'
module Objects
  class Spider < Chingu::GameObject
    trait :aggro
    trait :mover, damage: 1
    trait :swarmer
    trait :hp, hp: 1
    trait :bounding_box, debug: true

    def initialize(opts={})
      super(opts.merge image: Gosu::Image['spider.png'])
    end
  end

end
