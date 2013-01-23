require_relative 'base_level'
require_relative '../game_objects/bat'
require_relative '../game_objects/sniper'

module Levels
  class BossTestLevel < Level
    tilemap 'boss_lvl2.json'

    create_on \
      boss: Objects::Boss::Weaver
  end
end
