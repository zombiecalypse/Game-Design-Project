require_relative 'base_level'
module Levels
  class EnemyTestLevel < Level
    map do
      at(0,0).map('01_bg.png', '01_mask.png')

      at(700,800).object(:tower)
      at(800,700).object(:tower)

      at(200,200).startpoint :start
    end

    on(:tower) do |x,y|
      Objects::SimpleTower.create x: x, y: y
    end
  end
end
