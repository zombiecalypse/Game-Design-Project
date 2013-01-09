require_relative 'base_level'

module Levels
  class Level2 < Level
    tilemap 'level2.json'
    music "level one.ogg"

    create_on bat: Objects::Bat
  end
end
