require_relative 'base_level'
require_relative '../events/text_over'
module Levels
  class TextOverTestLevel < Level
    tilemap 'text_test.json'

    once :to1 do
      textover ["text over 1", "...and 2"]
    end

    def update
      super
      @to.update if @to
    end

    def draw
      super
      @to.draw if @to
    end
  end
end
