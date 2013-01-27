require_relative 'base_level'
require_relative '../game_objects/spider'

module Levels
  class BossLevel < Level
    tilemap 'boss_lvl2.json'

    create_on \
      boss: Objects::Boss::Weaver

    def create_spider
    end
  end
end
