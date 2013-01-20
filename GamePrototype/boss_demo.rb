require 'bundler'
Bundler.require

require_relative 'interface/gesture_controller'
require_relative 'menu/player_daemon'
require_relative 'game_objects/events'
require_relative 'levels/boss_test_level'

class Game < Chingu::Window
  def setup
    super
    self.input = { :i => :info}
    the(PlayerDaemon).teleport(level: Levels::BossTestLevel, point: :start)
  end
  
  def info
  	puts current_game_state
  end

  def needs_cursor?; true; end
end
Game.new.show
