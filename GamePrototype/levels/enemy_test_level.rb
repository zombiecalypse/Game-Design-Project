require_relative 'base_level'
require_relative '../game_objects/spider'
module Levels
  class EnemyTestLevel < Level
    map do
      at(0,0).map('01_bg.png', '01_mask.png')

      at(650,750).object(:tower)
      at(750,650).object(:tower)

      at(500,500).object(:spider)
      at(520,510).object(:spider)
      at(510,520).object(:spider)
      at(590,520).object(:spider)

      at(200,200).startpoint :start
    end

    on(:tower) do |x,y|
      Objects::SimpleTower.create x: x, y: y
    end

    on(:spider) do |x,y| 
      Objects::Spider.create x: x, y: y
    end
  end
end
