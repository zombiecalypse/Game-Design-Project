require 'rubygems'
require 'chingu'
require 'gosu'
require 'perftools'

require_relative 'interface/gesture_controller'
require_relative 'menu/player_daemon'
require_relative 'game_objects/events'
require_relative 'levels/enemy_test_level'

class Game < Chingu::Window
  def setup
    super
    self.input = { :i => :info}
    the(PlayerDaemon).teleport(level: Levels::EnemyTestLevel, point: :start)
  end
  
  def info
  	puts current_game_state
  end

  def needs_cursor?; true; end
end
Game.new.show
