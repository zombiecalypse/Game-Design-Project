require 'rubygems'
require 'chingu'
require 'gosu'

require_relative 'inputs/gesture_controller.rb'
require_relative 'levels/start_menu.rb'
require_relative 'game_objects/events.rb'

class Game < Chingu::Window
  def setup
    super
    push_game_state(Levels::StartMenu)
  end

  def needs_cursor?; true; end
end
Game.new.show
