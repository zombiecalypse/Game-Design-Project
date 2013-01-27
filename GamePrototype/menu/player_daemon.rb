require 'singleton'
require_relative '../helpers/the'
require_relative '../interface/hud_interface'
require_relative '../databases/weapons'
# Does the book-keeping for the player. Has the persistent instances for the
# player's connections and can then be connected to different Player instances
# across levels.
class PlayerDaemon
  include Singleton

  public
  def the; instance; end

  attr_reader :level, :journal, :hud, :player, :spellbook

  def initialize
    @hud = Interface::HudInterface.instance
    @spellbook = Databases::SpellBook.new
    @journal = Interface::Journal.new
    @journal.add_page("Hi", "I'm from the empire of Rubinus.")
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
    point = opts[:point]
    x,y   = opts[:position] || [(opts[:x] || 0), (opts[:y] || 0)]
    if need_planeshift? level
      do_planeshift(level, x,y, point)
    else
      state =$window.current_game_state 
      x,y = state[point] if point and state.respond_to? :[]
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

  def reset_instance
    @hud.reset_instance
    super
  end

  def need_planeshift? level
    @player.nil? or (not level.nil? and $window.current_game_state != level)
  end

  def do_planeshift level, x,y, point
    info = extract_info @player
    @player.destroy if @player
    $window.switch_game_state level
    state = $window.current_game_state

    x,y = state[point] if point and state.respond_to?(:[])

    @player = Objects::Player.create(info.merge! x: x, y: y, level: state, weapon: Weapons::default.new)
    @hud.player = @player
    @player.input = { 
      holding_a:             :move_left, 
      holding_d:             :move_right, 
      holding_w:             :move_up,
      holding_s:             :move_down,
      mouse_left:            :new_word,
      holding_mouse_right:   :record_gesture,
      mouse_right:           :new_gesture,
      mouse_left:            :action,
      released_mouse_right:  :finished_gesture}
  end
end
