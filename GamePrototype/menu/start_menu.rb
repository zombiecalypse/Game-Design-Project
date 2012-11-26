require 'rubygems'
require 'chingu'
require 'gosu'

require_relative '../levels/level'
require_relative 'menu'
require_relative '../interface/color_theme'

module Levels
  class StartMenu < Chingu::GameState
    def initialize(opts={})
      super opts
      @bg = Chingu::GameObject.create(image: 'title.png', x: $window.width/2, y: $window.height/2, zorder: ZOrder::BACKGROUND)
      @bg.scale = $window.width.to_f / @bg.width
      @title = Chingu::Text.create("Anura", x: 150, y: 50, size: 60, color: Colors::INACTIVE)
      @menu= Menu.create(menu_items: {
        "Start" => TestLevel,
        "Load"  => Interface::LoadScreen,
        "Exit"  => :exit
      }, size: 40)
    end
  end
end
