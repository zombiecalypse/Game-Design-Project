require 'rubygems'
require 'chingu'
require 'gosu'

require_relative 'interface/gesture_controller.rb'
require_relative 'menu/start_menu.rb'
require_relative 'game_objects/events.rb'

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
