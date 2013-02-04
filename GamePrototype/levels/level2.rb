require_relative 'base_level'
require_relative '../events/text_over'
require_relative '../levels/boss_level'

module Levels
  class Level2 < Level
    tilemap 'level2.json'
    music "level one.ogg"

    create_on \
      bat: Objects::Bat,
      soldier: Objects::Clockwork::Soldier,
      sniper: Objects::Clockwork::Sniper

    once :to1 do
      textover ["Bats swarm you", "but are easily killed by a fireball"]
    end

    once :guards_entry do
      textover ["Guard 1: He must have fled down here", "Guard 2: OK, don't take any chances"]
    end

    once :guards_afraid do
      textover ["Guard 3: The spiders grow huge down here", 
                "Guard 4: Yeah, we lost some patrols to them", 
                "Guard 3: That explains the \"Warning\" sign..."]
    end

    once :guards_spider do
      textover ["Guard 5: Ouch, that bastard bit me!", 
                "Guard 5: We'll just stay here", 
                "Guard 5: If that prisoner got any further...",
                "Guard 5: ... we can just let the spider queen take care of 'em"]
    end

    once :spider do
      textover ["I got a really bad feeling about this..."]
    end

    zone :teleport_spider do
      the(PlayerDaemon).teleport level: Levels::BossLevel, point: :start
    end
  end
end
