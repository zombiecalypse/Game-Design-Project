require 'singleton'
require_relative '../helpers/the'
require_relative '../interface/hud_interface'
# Does the book-keeping for the player. Has the persistent instances for the
# player's connections and can then be connected to different Player instances
# across levels.
class PlayerDaemon
  include Singleton

  attr_reader :level, :journal, :hud, :player, :spellbook

  def initialize
    @hud = Interface::HudInterface.new
    @spellbook = Databases::SpellBook.new
    @journal = Interface::Journal.new
  end

  # Teleports the player to the new position, which might be in a different
  # level. Like real teleportation, this might destroy the player and create a new
  # one at the requested position. This is necessary to ensure that cross-level
  # teleportation is save.
  #
  # [level] The level to teleport to. If different from the current level, the
  #         game state is switched, the player is destroyed and recreated at the
  #         new location.
  # [x,y | position] The position to teleport to. 'x' and 'y' must be given as a
  #                  pair or else the unset parameter is 0.
  def teleport opts={}
    level = opts[:level]
    x,y   = opts[:position] || [(opts[:x] || 0), (opts[:y] || 0)]
    if need_planeshift? level
      do_planeshift(level, x,y)
    else
      @player.x,@player.y = x,y
    end
  end

  def update
    @hud.update
  end

  private
  @@default_options = {
    hp: 100,
    dir: :down,
    speed: 3,
    vulnerability: 1
  }

  def extract_info player
    return @@default_options unless player

    player.extract_info
  end

  def need_planeshift? level
    @player.nil? or (not level.nil? and $window.current_game_state != level)
  end

  def do_planeshift level, x,y
    info = extract_info @player
    @player.destroy if @player
    $window.switch_game_state level
    @player = Objects::Player.create(info.merge! x: x, y: y)
  end
end
