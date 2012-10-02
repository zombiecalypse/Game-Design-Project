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
    sum/size
  end
end

class GameWindow < Gosu::Window
  def initialize
    super 640, 480, false
    self.caption = "Gesture Symbols"
    @@font ||= Gosu::Font.new(self, Gosu::default_font_name, 20)
    @last_sym = nil
  end

  def update
    @gesture_buffer << [mouse_x,mouse_y] if @gesture
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
    draw_last_symbol
  end

  def draw_last_symbol 
    @@font.draw(@last_symbol.to_s, 10, 10, 10, 1.0, 1.0, Gosu::Color::BLACK)
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
    Gosu::MsRight => :mouse_right
  }  
  def needs_cursor?; true; end

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
    puts symbol
    @last_symbol = symbol
  end

  def recognize list
    xs,ys = list.transpose
    dx,dy = [xs,ys].collect {|c| c.differences.avg}
    phi = Math.atan2(dx,dy)
    puts "dX: #{dx} dY: #{dy} phi: #{phi}"
    @last_dir_x, @last_dir_y = [dx,dy].collect {|e| e/Math.hypot(dx,dy)}
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
