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
      @bar = Chingu::GameObject.new x: 20, y: 20, image: Gosu::Image['health_bar.png']
      @out = Chingu::GameObject.new x: 20, y: 20, image: Gosu::Image['health_bar_out.png']
      @bar.center = 0
      @out.center = 0
      @gesture_icons = Chingu::Animation.new(file: 'arrow.png', size: 100)
      @gesture_icons.frame_names = {
        left:  0,
        up:    1,
        right: 2,
        down:  3,
        arc:   4}
    end

    def update
      @bar.factor_x = @player.hp.to_f/@player.max_hp
      @icon.update if @icon
    end

    def textover txt
      @textover = TextOver.new texts: txt, x: 500, y: 300
      @textover.activate
    end

    def draw
      @bar.draw
      @out.draw
      @textover.draw if @textover
      @icon.draw if @icon
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
      Icon.new icon, self
    end

    attr_accessor :icon

    class Icon < Chingu::GameObject
      trait :timer
      trait :effect

      def initialize(img, parent)
        super({image: img}.merge(x: $window.width/2, y: 2*$window.height/3,
                              scale_rate: 0.2,
                              fade_rate: -10,
                              mode: :default))
        parent.icon = self
        after(1000) { destroy; parent.icon = nil}
      end

      def update
        update_trait
        super
      end
    end
  end
end
