# encoding: utf-8
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
      textover [
        "Bats swarm you", 
        "but are easily killed by a fireball.",
        "To activate a spell, you have to use its formula",
        "by pressing the right mouse button",
        "pulling the mouse left, right, up, or down",
        "then releasing and enter the next symbol.",
        "A fireball has the formula ↑↓" ]
    end

    once :blast do
      textover [
        "You can push your enemies away from you",
        "with a blast triggered by ←→↓",
        "It does massive damage, if enemies",
        "are pushed into walls"
      ]
    end

    once :shield do
      textover [
        "If you cannot escape an attack",
        "you can still minimize the damage",
        "by activating a shield before being hit",
        "The spell ↑→↓← makes attacks deal only",
        "20% damage for 5 seconds"
      ]
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
