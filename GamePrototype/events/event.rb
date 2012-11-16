#TODO fix behavior for @repeat = true

require 'chingu'

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
		super(mode, opts) #block
		@conversation = conversation
	end
	
	def activate
		return unless @active
		@conversation.activate
		@block.call
		@active = @repeat ? true : false
	end
end

class Tile < Chingu::GameObject
	trait :bounding_box, debug: true
	trait :collision_detection
	
	def initialize (event, x, y, w, h, opts={})
		super({image: Gosu::Image['platform.png'], :x => 400, y: 400}.merge!(opts))
		#TODO fix bounding box
		#super opts
		@event = event
		@area = Chingu::Rect.new(x,y,w,h)
	end
	
	def collision_at?(x, y)
		@area.collide_point?(x,y)
	end
	
	def update
		each_collision(Objects::Player) do
			@event.activate
		end
	end
		
	#def width
	#	100
	#end
	
	#def height
	#	100
	#end
	
	#def size
	#	[width, height]
	#end
	
end

ON_HIT = 0		# event is triggered when player enters area
ON_CLICK = 1	# event is triggered when object is clicked on
ON_SCENE = 2	# event is triggered when player enters level 
