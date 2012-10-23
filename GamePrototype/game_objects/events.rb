require 'rubygems'
require 'chingu'
require 'gosu'
require 'logger'
require 'texplay'


module Objects
	class EventTrigger < Chingu::GameObject
		trait :bounding_box
		
		def initialize (opts={})
			super opts
      @event = Events::Conversation.new opts if opts[:lines]
      @once = opts[:once]
		end
		
		def setup
			@image = Gosu::Image["platform.png"]
		end

    def update
      each_collision(Player) do
        @event.render if @event
        self.destroy if @once
      end
    end
	end
end
