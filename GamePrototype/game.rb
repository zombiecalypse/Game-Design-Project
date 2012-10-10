require 'rubygems'
require 'chingu'
require 'gosu'

require_relative 'inputs/gesture_controller.rb'
require_relative 'levels/start_menu.rb'


class Game < Chingu::Window
  def setup
    super
    push_game_state(Levels::TestLevel)
  end

  def needs_cursor?; true; end
end
Game.new.show
