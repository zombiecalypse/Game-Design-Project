require 'rubygems'
require 'chingu'
require 'gosu'

require_relative 'level'
require_relative 'menu'

module Levels
  class StartMenu < Chingu::GameState
    def initialize(opts={})
      super opts
      @bg = Chingu::GameObject.create(image: Gosu::Image['title.png'], x:0, y:0, center:0)
      @menu= Menu.create(menu_items: {
        "Start" => TestLevel,
        "Exit"  => :exit
      }, size: 40)
      @menu.input= {
        [:w, :up]                      => lambda {@menu.step(1)},
        [:s, :down]                    => lambda {@menu.step(-1)},
        [:return, :space, :mouse_left] => lambda {@menu.select}
      }
    end
  end
end
