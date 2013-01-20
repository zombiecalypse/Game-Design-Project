require_relative 'base_level'
require_relative '../game_objects/bat'
require_relative '../game_objects/sniper'

module Levels
  class BossTestLevel < Level
    map do
      at(0,0).map('01_bg.png', '01_mask.png')

      at(200, 200).object(:boss)

      at(400,700).startpoint :start
    end

    create_on \
      boss: Objects::Boss::Weaver
  end
end
