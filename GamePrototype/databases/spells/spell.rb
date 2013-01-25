
class Spell
  attr_reader :name
  # Options:
  #   name: Used for display
  #   activation: Is the spell held back until the player clicks somewhere?
  #   icon: Is displayed when the gesture is complete to inform the player
  #   sound: The sound played on activation (if it is used) or running
  #
  # block: is executed on activation (if used) or running with the following
  #        parameters:
  #   x,y: the point, where the player clicked if activation
  #   dx, dy: difference to the player coordinates
  #   phi: the angle in which the player clicked
  #   player: the player object
  def initialize opts={}, &block
    @name = opts[:name]
    @activation = opts[:activation]
    @icon = opts[:icon]
    @sound = opts[:sound]
    @block = block
    invariant
  end

  def invariant
    raise "No name" unless @name
    raise "No icon" unless @icon
    raise "No block" unless @block
  end

  def run player
    the(Interface::HudInterface).spell_notification(@icon)
    if @activation
      player.spell = self
      @player = player
    else
      @sound.play if @sound
      @block.call player: player
    end
  end

  def activate x,y
    @sound.play if @sound
    @player.spell = nil
    dx = x - @player.x_window
    dy = y - @player.y_window
    phi = Math::atan2(dy,dx)
    @block.call player: @player, 
      x: x, y: y, 
      dx: dx, dy: dy,
      phi: phi
  end
end
