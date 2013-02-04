require_relative 'base_level'

module Levels
  class Level1 < Level
    tilemap 'level1a.json'
    music "level one.ogg"

    create_on soldier: Objects::Clockwork::Soldier
  end
end
