require 'bundler'
Bundler.require

require_relative 'interface/gesture_controller'
require_relative 'menu/start_menu'
require_relative 'game_objects/events'

class Game < Chingu::Window
  def setup
    super
    self.input = { :i => :info}
    push_game_state(Levels::StartMenu)
  end
  
  def info
  	puts current_game_state
  end

  def needs_cursor?; true; end
end
Game.new.show
