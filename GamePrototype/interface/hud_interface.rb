require 'rubygems'
require 'chingu'
require 'gosu'

require_relative 'z_orders'

module Interface
  class HudInterface
    attr_accessor :player

    def update
      @hp_text = Chingu::Text.new(hp_string, x: 20, y: 20, color: Gosu::Color::BLACK, zorder: ZOrder::HUD)
    end

    def hp_string
      "HP: #{@player.hp}/#{@player.max_hp}" rescue "No Player"
    end

    def draw
      @hp_text.draw if @hp_text
    end
  end
end
