require 'texplay'
module Levels
  class Map < Chingu::GameObject
    def initialize opts={}
      super({zorder: ZOrder::MAP}.merge(opts))
      @mask = opts[:mask] || self.image
    end

    def blocked? x,y
      is_wall?(@mask.get_pixel(x,y)) rescue false
    end

    def is_wall? pixel
      r,g,b,a = pixel
      r < 0.1 and g < 0.1 and b < 0.1 and a > 0.99
    end
  end
end
