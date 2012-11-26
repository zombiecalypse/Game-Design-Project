require_relative 'menu'
require_relative '../interface/save_screen'
require_relative '../game_objects/player'
module Levels
  class PauseMenu < Chingu::GameState
    def initialize(opts={})
      super
      @bg = Colors::BACKGROUND
      @menu = Menu.create(menu_items: {
        "Continue" => lambda {pop_game_state(setup: false)},
        "Journal"  => lambda {Objects::Player.the.journal.show},
        "Save"     => lambda {$window.push_game_state Interface::SaveScreen},
        "Load"     => lambda {$window.push_game_state Interface::LoadScreen},
        "Exit"     => :exit
      })
    end

    include Chingu::Helpers::GFX

    def draw
      fill(@bg)
      super
    end
  end
end
