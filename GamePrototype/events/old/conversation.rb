require 'chingu'
module Events
  class Conversation < Chingu::GameState
    def initialize opts={}
      super
      @width, @height =  opts[:width] || 300, opts[:height] || 200
      @x = opts[:x] || $window.width/2 - @width/2 rescue 0
      @y = opts[:y] || 2*$window.height/3 - @width/2 rescue 0
      @align = opts[:align] || :left
      @fg = opts[:fg] || Gosu::Color::WHITE
      @bg = opts[:bg] || Gosu::Color.new(220, 0,0,0)
      @original_lines = opts[:lines]
      @lines = opts[:lines].reverse
      @text = as_text @lines.pop
      self.input = {
        [:mouse_left, :mouse_right, :space, :enter] => :forward
      }
    end

    def lines
      @original_lines
    end

    def as_text txt
      Chingu::Text.new(txt.render, x: @x + 20, y: @y + 10, align: @align, zorder: 1001) rescue nil
    end

    def render
      $window.push_game_state self
    end

    def forward
      @text = as_text @lines.pop
      quit_dialog unless @text
    end

    def quit_dialog
      pop_game_state
    end

    def draw
      previous_game_state.draw

      $window.draw_quad(
          @x                 , @y        , @bg,
          @width+@x          , @y        , @bg,
          @width+@x          , @y+@height, @bg,
          @x                 , @y+@height, @bg, 1000)
      @text.draw if @text
    end
  end

  class Popup
    attr_reader :lines

    def initialize opts={}
      @lines = opts[:lines]
    end

    def render
      @lines
    end

    def == other
      return false if not other.respond_to? :lines
      lines == other.lines
    end

    def to_s
      render
    end
  end
end
