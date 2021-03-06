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

    create_on \
      tower:   Objects::SimpleTower,
      bat:     Objects::Bat,
      sniper:  Objects::Clockwork::Sniper,
      soldier: Objects::Clockwork::Soldier
  end
end
