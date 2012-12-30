require 'rubygems'
require 'chingu'
require 'gosu'
require 'logger'

require_relative '../events/event'
require_relative '../events/conversation'
require_relative '../menu/pause_menu'
require_relative '../game_objects/simple_tower'
require_relative '../interface/hud_interface'
require_relative 'map'

module Levels
  LOREM_IPSUM = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur id tortor a nunc convallis aliquam. Pellentesque velit velit, ornare a lacinia nec, egestas id augue. Suspendisse ac eros sem, vel molestie est. Aliquam velit massa, venenatis in tincidunt sit amet, posuere eget nibh. Integer bibendum auctor diam, eu condimentum sem convallis sed. Sed id odio ut massa tincidunt mollis placerat sit amet tellus. Morbi at odio felis, non luctus felis. Maecenas vehicula tortor nec nibh pulvinar hendrerit. Duis scelerisque viverra consequat.

Quisque rutrum erat eget sapien sagittis et pharetra risus cursus. Etiam at odio nunc, ac viverra tortor. In hac habitasse platea dictumst. Phasellus aliquet urna vitae velit dignissim elementum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Phasellus nisi risus, mollis nec egestas at, sodales et magna. Sed diam ante, mollis in elementum fringilla, posuere eget nulla.
"

  class TestLevel < Chingu::GameState
    trait :viewport

    attr_reader :player
    def initialize(opts = {})
      super(opts)
      @map = Map.create do
        at(0,0).map('level one - 1.png', 'mask one - 1.png')
        at(960,0).map('level one - 2.png', 'mask one - 2.png')
      end
      @level_width = 1344
      @level_height = 640
      self.viewport.lag = 0
      self.viewport.game_area = [0.0, 0.0, @level_width, @level_height]
      Gosu::Song["level one.ogg"].play(true)
      @log = Logger.new(STDOUT)
      #load_events
      log_info {"Database loaded"}
      @camera = @player = Objects::Player.create x: 160, y: 160, level: self
      @player.journal.add_page("The History of Awesomevile", "It was and has always been")
      @player.journal.add_page("The History of Suckvile", "It was empty, until Sucky McSuckerson moved in.")
      @player.journal.add_page("The History of History", LOREM_IPSUM)
      #@tower = Objects::SimpleTower.create x: 700, y: 700
      @hud = Interface::HudInterface.new(@player)
      log_info { "entering" }
    end

    def load_events
    	d1 = Dialog.new("Who are you?",["Claudio","Aaron","The chosen One"])
      d2 = Dialog.new("What do you want?",["Program","Code","Kill a Dragon"])
      d1.next_dialog = d2
      con = Conversation.new(d1)
      Con_Event.new(ON_HIT, con, {x: 400, y: 400, w: 100, h:50}) {puts "Event done"}
      
      line = "Brace yourself if you pass this Point"
      Pop_Event.new(ON_HIT, line, {x: 300, y: 600, w: 50, h:50})
      
      Event.new(ON_HIT,{x:100, y:600, w:100, h:100}) {Objects::SimpleTower.create x: 100, y: 600;
      																								Objects::SimpleTower.create x: 300, y: 600;
      																								Objects::SimpleTower.create x: 200, y: 750;
      																								Objects::SimpleTower.create x: 200, y: 450}
    end

    def finalize
      log_info { "exiting" }
    end

    def log_info &block                                                      
      @log.info("TestLevel", &block)
    end

    def blocked? x,y
      return true if x < 0 or y < 0
      return true if x > @level_width or y > @level_height
      return true if @map.blocked? x,y 
    end

    def can_move_to? x,y
      not blocked? x,y
    end

    def debug_state
      push_game_state Chingu::GameStates::Debug
    end

    def setup
      super
      self.input = {
        esc:                   :open_menu,
        F1:                    :debug_state
      }
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

    def open_menu
      push_game_state PauseMenu
    end

    def update_hud
      @hud.update
      viewport.center_around @camera
    end
    
    def draw
      draw_background
      super
      @hud.draw
    end

    def draw_background
      fill(Gosu::Color::WHITE, ZOrder::BACKGROUND)
    end

    def update
      super
      self.viewport.center_around @player
    end

  end
end
