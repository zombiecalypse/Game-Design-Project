require 'rubygems'
require 'chingu'
require 'gosu'

require_relative '../levels/level'
require_relative 'menu'

module Levels
  class StartMenu < Chingu::GameState
    def initialize(opts={})
      super opts
      @bg = Chingu::GameObject.create(image: 'title.png', x: $window.width/2, y: $window.height/2)
      @bg.scale = $window.width.to_f / @bg.width
      @menu= Menu.create(menu_items: {
        "Start" => TestLevel,
        "Exit"  => :exit
      }, size: 40)
    end
  end
end
