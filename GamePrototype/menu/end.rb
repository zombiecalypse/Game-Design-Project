require_relative 'start_menu'
module Levels
  class End < Chingu::GameState
    def initialize(opts={})
      super opts
      @bg = Chingu::GameObject.create(image: 'end.png', x: $window.width/2, y: $window.height/2, zorder: ZOrder::BACKGROUND)
      @bg.scale = $window.width.to_f / @bg.width
      self.input = {
        esc: :main_menu
      }
    end

    def main_menu
      switch_game_state(StartMenu)
    end
  end
end
