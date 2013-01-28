require_relative 'base_level'
require_relative '../events/text_over'
require_relative '../levels/boss_level'

module Levels
  class Level1 < Level
    tilemap 'level1.json'
    music "level one.ogg"

    create_on bat: Objects::Bat

    once :spider do
      textover ["I got a really bad feeling about this..."]
    end

    zone :teleport_spider do
      the(PlayerDaemon).teleport level: Levels::BossLevel, point: :start
    end
  end
end
