require 'rubygems'
require 'chingu'
require 'gosu'
require 'logger'

require_relative '../events/event'
require_relative '../events/conversation'
require_relative '../menu/pause_menu'
require_relative '../game_objects/simple_tower'
require_relative '../interface/hud_interface'
require_relative '../interface/z_orders'
require_relative 'map'
require_relative 'base_level'

module Levels
  LOREM_IPSUM = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur id tortor a nunc convallis aliquam. Pellentesque velit velit, ornare a lacinia nec, egestas id augue. Suspendisse ac eros sem, vel molestie est. Aliquam velit massa, venenatis in tincidunt sit amet, posuere eget nibh. Integer bibendum auctor diam, eu condimentum sem convallis sed. Sed id odio ut massa tincidunt mollis placerat sit amet tellus. Morbi at odio felis, non luctus felis. Maecenas vehicula tortor nec nibh pulvinar hendrerit. Duis scelerisque viverra consequat.

Quisque rutrum erat eget sapien sagittis et pharetra risus cursus. Etiam at odio nunc, ac viverra tortor. In hac habitasse platea dictumst. Phasellus aliquet urna vitae velit dignissim elementum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Phasellus nisi risus, mollis nec egestas at, sodales et magna. Sed diam ante, mollis in elementum fringilla, posuere eget nulla.
"

  class Level1 < Level
    map do
      at(0,0).map('level one - 1.png', 'mask one - 1.png')
      at(960,0).map('level one - 2.png', 'mask one - 2.png')

      at(200,200).object :tower

      at(150,150).startpoint :start
    end

    music "level one.ogg"

    on(:tower) do |x,y|
      Objects::SimpleTower.create x: x, y: x
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

  end
end
