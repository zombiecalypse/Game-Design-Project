
module Events
  class Tile < Chingu::GameObject
    trait :bounding_box
    trait :collision_detection

    attr_reader :event
    def initialize(opts={})
      super({image: Gosu::Image['platform.png']}.merge!(opts))
      @event = opts[:event]
    end


    def update
      each_collision(Objects::Player) do |me, player|
        me.event.hit.each do |e|
          e.render
        end
      end
    end
  end
end
