require 'gosu'

class Array
  def differences
    arr = []
    self[0..-2].each_index do |i|
      arr << (self[i+1]-self[i])
    end
    arr
  end

  def sum
    self.inject(0,:+)
  end

  def avg
    sum/size rescue 0
  end
end

class Player
  attr_accessor :symbols

  attr_reader :x,:y, :last_dir

  def x= nx
    @last_dir = :left if nx < x
    @last_dir = :right if nx > x
    @x = nx
  end

  def y= ny
    @last_dir = :up if ny < y
    @last_dir = :down if ny > y
    @y = ny
  end


  def initialize
    @x, @y = 0,0

    self.symbols = []
  end

  def symbol s
    return nil unless s
    puts s
    symbols << s
    rec = recognize(symbols)
    self.symbols = [] if rec
    return rec
  end

  def recognize(syms)
    return :fire if syms == [:up, :up]
  end
end

class GameWindow < Gosu::Window
  attr_accessor :player
  def initialize
    super 640, 480, false
    self.caption = "Gesture Symbols"
    self.player = Player.new
    @@font ||= Gosu::Font.new(self, Gosu::default_font_name, 20)
  end

  def update
    @gesture_buffer << [mouse_x,mouse_y] if @gesture
    player.x -= 2 if button_down? Gosu::KbA
    player.x += 2 if button_down? Gosu::KbD
    player.y -= 2 if button_down? Gosu::KbW
    player.y += 2 if button_down? Gosu::KbS
  end

  def draw_rect bl, tr, color
    l,b = bl
    r,t = tr
    draw_quad(l,b,color,l,t, color, r,t,color, r,b,color)
  end

  def clear
    draw_rect([0,0], [640,480], Gosu::Color::WHITE)
  end

  def draw
    clear
    draw_buffer if @gesture_buffer
    draw_direction
    draw_symbols
    draw_player
    draw_spell_effect
  end

  def draw_spell_effect
    if @last_spell and (Gosu::milliseconds - @last_spell_time) < 1000
      orange = Gosu::Color::rgba(0xdfa30d4a)
      px, py = player.x + 320, player.y + 240
      range = 100
      if player.last_dir == :down
        draw_triangle(
          px, py, orange, 
          px + range, py + range, orange, 
          px - range, py + range, orange)
      elsif player.last_dir == :up or player.last_dir.nil?
        draw_triangle(
          px, py, orange, 
          px + range, py - range, orange, 
          px - range, py - range, orange)
      elsif player.last_dir == :right
        draw_triangle(
          px, py, orange, 
          px + range, py - range, orange, 
          px + range, py + range, orange)
      elsif player.last_dir == :left
        draw_triangle(
          px, py, orange, 
          px - range, py - range, orange, 
          px - range, py + range, orange)
      end
    end
  end

  def draw_player
    x,y = player.x+320, player.y+240
    draw_rect([x - 10, y-10], [x+10, y+10], Gosu::Color::RED)
  end

  def draw_symbols 
    @@font.draw(player.symbols.collect(&:to_s).join(", "), 10, 10, 10, 1.0, 1.0, Gosu::Color::BLACK)
    @@font.draw(@last_spell, 300, 400, 10, 1.0, 1.0, Gosu::Color::BLACK)
  end

  def button_down id
    sym = @@button_mapping[id]
    method = (sym.to_s+"_down").to_sym
    self.send(method) if sym
  end

  def button_up id
    sym = @@button_mapping[id]
    method = (sym.to_s+"_up").to_sym
    self.send(method) if sym
  end

  @@button_mapping = {
    Gosu::MsRight => :mouse_right,
    Gosu::MsLeft  => :mouse_left
  }  
  def needs_cursor?; true; end

  def mouse_left_down
    @player.symbols = []
  end

  def mouse_left_up
  end

  def mouse_right_down
    @gesture = true
    @gesture_buffer = [[mouse_x, mouse_y]]
  end

  def draw_buffer
    oldx, oldy = @gesture_buffer.first
    @gesture_buffer.each do |mx,my|
      draw_line(oldx, oldy, Gosu::Color::BLACK, mx, my, Gosu::Color::BLACK)
      oldx, oldy = mx, my
    end
  end

  def draw_direction
    return nil unless @last_dir_x and @last_dir_y
    draw_line(100,100, Gosu::Color::BLACK, 100+@last_dir_x*50, 100+@last_dir_y*50, Gosu::Color::BLACK)
  end
  
  def mouse_right_up
    @gesture = false
    symbol = recognize(@gesture_buffer)
    @last_spell  = player.symbol(symbol)
    @last_spell_time = Gosu::milliseconds
  end

  def recognize list
    xs,ys = list.transpose
    dx,dy = [xs,ys].collect {|c| c.differences.avg}
    phi = Math.atan2(dx,dy) rescue 0
    puts "dX: #{dx} dY: #{dy} phi: #{phi}"
    @last_dir_x, @last_dir_y = [dx,dy].collect {|e| (e/Math.hypot(dx,dy) rescue 0)}
    return :down  if dy > 0 and dy.abs > dx.abs
    return :left  if dx < 0 and dy.abs < dx.abs
    return :up    if dy < 0 and dy.abs > dx.abs
    return :right if dx > 0 and dy.abs < dx.abs
  end

  def self.run
    self.new.show
  end
end

GameWindow.run
