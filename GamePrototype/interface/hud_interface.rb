require 'rubygems'
require 'chingu'
require 'gosu'
require 'singleton'

require_relative 'z_orders'

module Interface
  class HudInterface
    include Singleton
    attr_accessor :player, :gesture_icons

    def initialize
      @gesture_icons = Chingu::Animation.new(file: 'arrow.png', size: 100)
      @gesture_icons.frame_names = {
        left:  0,
        up:    1,
        right: 2,
        down:  3,
        arc:   4}
    end

    def update
      @hp_text = Chingu::Text.new(hp_string, x: 20, y: 20, color: Gosu::Color::BLACK, zorder: ZOrder::HUD)
    end

    def hp_string
      "HP: #{@player.hp}/#{@player.max_hp}" rescue "No Player"
    end

    def draw
      @hp_text.draw if @hp_text
      x = 400
      return unless @gesture_icons
      @player.current_gesture.each do |sym|
        arrow = @gesture_icons[sym]
        if arrow
          arrow.draw(x,20,ZOrder::HUD, 0.5, 0.5)
          x += arrow.width 
        end
      end
    end

    def spell_notification icon
      Icon.create icon
    end

    class Icon < Chingu::Particle
      trait :timer

      def initialize(img)
        super({image: img}.merge(x: $window.width/2, y: 2*$window.height/3,
                              scale_rate: 0.2,
                              fade_rate: -10,
                              mode: :default))
        after(1000) {self.destroy}
      end
    end
  end
end
