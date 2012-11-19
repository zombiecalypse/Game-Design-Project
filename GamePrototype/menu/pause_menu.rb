require_relative 'menu'
require_relative '../game_objects/player'
module Levels
  class PauseMenu < Chingu::GameState
    def initialize(opts={})
      super
      @bg = Gosu::Color::BLACK
      @menu = Menu.create(menu_items: {
        "Continue" => lambda {pop_game_state(setup: false)},
        "Journal"  => lambda {Objects::Player.the.journal.show},
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
