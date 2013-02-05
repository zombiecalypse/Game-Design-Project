require_relative 'base_level'
require_relative '../levels/level2'

module Levels
  class Level1 < Level
    tilemap 'level1.json'
    music "level one.ogg"

    create_on soldier: Objects::Clockwork::Soldier
    
    once :to1 do
      @map.wall_tiles.each{|s| s.each{|t| t.hidden = false if t}}
      zones[:teleport_level2] = Proc.new do the(PlayerDaemon).teleport level: Levels::Level2, point: :start end
    end
    
  
  end
end
