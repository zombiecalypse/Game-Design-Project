require 'rubygems'
require 'chingu'
require 'gosu'
require 'logger'
require 'texplay'


	class ConversationEvent < Chingu::GameObject
		trait :bounding_box
		
		def initialize (opts={})
			super opts
		end
		
		def setup
			@image = Gosu::Image["platform.png"]
			self.factor = 1
		end
	end

	
	

