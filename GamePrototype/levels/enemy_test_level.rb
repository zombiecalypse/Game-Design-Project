require_relative 'base_level'
require_relative '../game_objects/bat'
require_relative '../game_objects/sniper'

module Levels
  class EnemyTestLevel < Level
    map do
      at(0,0).map('01_bg.png', '01_mask.png')

      at(650,750).object(:tower)
      at(750,650).object(:tower)

      at(500,500).object(:bat)
      at(520,510).object(:bat)
      at(510,520).object(:bat)
      at(590,520).object(:bat)

      at(700, 400).object(:sniper)

      at(400, 700).object(:soldier)

      at(200,200).startpoint :start
    end

    on(:tower) do |x,y|
      Objects::SimpleTower.create x: x, y: y
    end

    on(:bat) do |x,y| 
      Objects::Bat.create x: x, y: y
    end

    on(:sniper) do |x,y| 
      Objects::Clockwork::Sniper.create x: x, y: y
    end

    on(:soldier) do |x,y| 
      Objects::Clockwork::Soldier.create x: x, y: y
    end
  end
end
