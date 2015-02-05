#TODO fix behavior for @repeat = true

require 'rubygems'
require 'chingu'
require 'gosu'
require 'logger'

class Event
	attr_accessor :active

	def initialize (mode, opts={}, &block)
		@mode = mode
		case @mode
		when ON_HIT
			Tile.create( self,
								opts[:x] || 0,
								opts[:y] || 0,
								opts[:w] || 0,
								opts[:h] || 0,)
		#TODO add other modes
		end
		@repeat = opts[:repeat].nil? ? false : opts[:repeat]
		@active = opts[:active].nil? ? true : opts[:active]
		@block = block
	end

	def activate
		return unless @active
		@block.call
		@active = @repeat ? true : false
	end
end

class Con_Event < Event
	def initialize (mode, conversation, opts = {}, &block)
		super(mode, opts)
		@conversation = conversation
		@conversation.block = block
	end

	def activate
		return unless @active
		@conversation.activate
		@active = @repeat ? true : false
	end
end

class Pop_Event < Event
	def initialize (mode, line, opts = {})
		super(mode, opts)
		@line = line
		@x = opts[:x]
		@y = opts[:y]
		@active = true
	end

	def activate
		return unless @active
		$window.push_game_state(Popup.new(@line, @x, @y))
		@active = false
	end
end

class Tile < Chingu::GameObject
	trait :bounding_box
	trait :collision_detection

	def initialize (event, x, y, w, h, opts={})
		super opts
		@event = event
		@x = x
		@y = y
		@w = w
		@h = h
		@area = Chingu::Rect.new(x-(w/2),y-(h/2),w,h)

	end

	def collision_at?(x, y)
		@area.collide_point?(x,y)
	end

	def update
		each_collision(Objects::Player) do
			@event.activate
		end
	end

	def draw
		$window.fill_rect(@area,Gosu::Color::BLUE)
	end

	def x
		@x
	end

	def y
		@y
	end

	def size
		[@w, @h]
	end

end

ON_HIT = 0		# event is triggered when player enters area
ON_CLICK = 1	# event is triggered when object is clicked on
ON_SCENE = 2	# event is triggered when player enters level
