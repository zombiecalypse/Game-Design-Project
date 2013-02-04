require_relative 'base_level'
require_relative '../game_objects/spider'

module Levels
  class BossLevel < Level
    tilemap 'boss_lvl2.json'

    create_on \
      boss: Objects::Boss::Weaver

    def create_spider
      [:spider_spawn1, :spider_spawn2].each do |point|
        x,y = map.startpoints[point]
        spider = Objects::Spider.create(x: x, y: y)
        spider.notice the Objects::Player
      end
    end

    def healing_blocked?
      true
    end
  end
end
