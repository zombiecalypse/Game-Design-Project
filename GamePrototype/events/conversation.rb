require 'chingu'

class Conversation < Chingu::GameState
	def initialize (dialogs, opts={})
		#super opts
		@dialogs = dialogs
	end
	
	def click
		quit_conversation
	end
	
	def start
		height, width = $window.height, $window.width
		@question_board = Chingu::Rect.new(0, 3*height/4, width, height/16)
		@answer_board = Chingu::Rect.new(0, 13*height/16, width, 3*height/16)
		@qb_color = Gosu::Color.new(0xdc000000)
		@ab_color = Gosu::Color.new(0xa0c3c3c3)
		self.input = {:mouse_left => :click}
		$window.push_game_state self
	end
	
	def draw
		previous_game_state.draw if previous_game_state
		$window.fill_rect(@question_board, @qb_color, 1)
		$window.fill_rect(@answer_board, @ab_color, 1)
	end
	
	def quit_conversation
		pop_game_state
	end
	
end

class Dialog
	attr_accessor :question, :answers
	def initialize (question, answers)
		@question = question
		@answer = answer
	end
end
