require 'rubygems'
require 'chingu'
require 'gosu'

require_relative '../levels/level'
require_relative 'menu'

module Levels
  class StartMenu < Chingu::GameState
    def initialize(opts={})
      super opts
      @bg = Gosu::Image['title.png']
      @menu= Menu.create(menu_items: {
        "Start" => TestLevel,
        "Exit"  => :exit
      }, size: 40)
    end

    def draw
      super
      @bg.draw(0,0,0)
    end
  end
end
