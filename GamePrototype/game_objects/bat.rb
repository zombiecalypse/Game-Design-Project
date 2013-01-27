require_relative '../object_traits/swarmer'
require_relative '../object_traits/mover'
require_relative '../object_traits/hp'
require_relative '../object_traits/aggro'
module Objects
  class Bat < Chingu::GameObject
    does 'helpers/logging'

    trait :aggro, damage: 1
    trait :mover
    trait :swarmer
    trait :hp, hp: 5
    trait :bounding_circle, debug: true
    trait :asynchronous

    def initialize(opt={})
      @animation = Chingu::Animation.new file: 'bat.png', size: [90,30], delay: 150, bounce: true
      log_debug { "#{@animation.frames}" }
      super opt.merge image: @animation.image
    end

    def update
      super
      self.image = @animation.next
    end

    blocked_if do |x,y|
      parent.blocked? x,y
    end

    on_notice { |p| move_to p }
  end

end
