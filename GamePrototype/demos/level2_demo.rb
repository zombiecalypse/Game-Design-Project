require 'bundler'
Bundler.require

require_relative '../interface/gesture_controller'
require_relative '../menu/player_daemon'
require_relative '../game_objects/events'
require_relative '../levels/level2'

class Game < Chingu::Window
  def setup
    super
    self.input = { :i => :info}
    the(PlayerDaemon).teleport(level: Levels::Level2, point: :start)
  end
  
  def info
  	puts current_game_state
  end

  def needs_cursor?; true; end
end
Game.new.show
