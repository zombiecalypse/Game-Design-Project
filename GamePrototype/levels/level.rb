require 'rubygems'
require 'chingu'
require 'gosu'
require 'logger'

require_relative '../events/event'
require_relative '../events/conversation'
require_relative '../menu/pause_menu'
require_relative '../game_objects/simple_tower'
require_relative '../interface/hud_interface'
require_relative '../interface/z_orders'
require_relative 'map'
require_relative 'base_level'

module Levels
  class Level1 < Level
    map do
      at(0,0).map('level one - 1.png', 'mask one - 1.png')
      at(960,0).map('level one - 2.png', 'mask one - 2.png')

      at(200,200).object :tower

      at(150,150).startpoint :start
    end

    music "level one.ogg"

    create_on tower: Objects::SimpleTower
  end
end
