require_relative 'menu'
module Levels
  class PauseMenu < Chingu::GameState
    def initialize(opts={})
      super
      @bg = Gosu::Color::BLACK
      @menu = Menu.create(menu_items: {
        "Continue" => lambda {pop_game_state},
        "Exit" => :exit
      })
      @menu.input= {
        [:w, :up]                      => lambda {@menu.step(1)},
        [:s, :down]                    => lambda {@menu.step(-1)},
        [:return, :space, :mouse_left] => lambda {@menu.select}
      }
    end

    include Chingu::Helpers::GFX

    def draw
      fill(@bg)
      super
    end
  end
end
