require 'chingu'

class Conversation
	attr_accessor :dialog, :block
	
	def initialize(dialog)
		@dialog = dialog
	end
	
	def activate
		$window.push_game_state(ConversationState.new(self))
	end
	
	def finalize
		@block.call
	end
	
end

class ConversationState < Chingu::GameState
	def initialize (conversation, opts={})
		super opts
		@conversation = conversation
		@dialog = conversation.dialog
		@height, @width = $window.height, $window.width
		@qb_color = Gosu::Color.new(0xdc000000)
		@ab_color = Gosu::Color.new(0xa0c3c3c3)
		@qt_color = Gosu::Color::WHITE
		@at_color = Gosu::Color::BLACK
		@selected_color = Gosu::Color.new(0xffffba00)
		update_text
	end
	
	def click
		x, y = $window.mouse_x, $window.mouse_y
		choose_answer(x,y) if y > 13*@height/16
	end
	
	def update_text
		@q_text = Chingu::Text.new(@dialog.question, x: 0, y: 3*@height/4, color: @qt_color, zorder: ZOrder::POPUP)
		@a1_text = Chingu::Text.new(@dialog.answers[0], x: 0, y: 13*@height/16, color: @at_color, zorder: ZOrder::POPUP)
		@a2_text = Chingu::Text.new(@dialog.answers[1], x: 0, y: 14*@height/16, color: @at_color, zorder: ZOrder::POPUP)
		@a3_text = Chingu::Text.new(@dialog.answers[2], x: 0, y: 15*@height/16, color: @at_color, zorder: ZOrder::POPUP)	
	end
	
	def choose_answer(x,y)
		@dialog = @dialog.next_dialog
		if @dialog 
			update_text 
		else 
			quit_conversation
			@conversation.finalize
		end
	end
	
	def setup
		@question_board = Chingu::Rect.new(0, 3*@height/4, @width, @height/16)
		@answer_board1 = Chingu::Rect.new(0, 13*@height/16, @width, @height/16+1)
		@answer_board2 = Chingu::Rect.new(0, 14*@height/16, @width, @height/16)
		@answer_board3 = Chingu::Rect.new(0, 15*@height/16, @width, @height/16)
		self.input = {:mouse_left => :click}
	end
	
	def draw
		previous_game_state.draw
		answer1_color, answer2_color, answer3_color = @ab_color, @ab_color, @ab_color
		case $window.mouse_y
			when (13*@height/16)...(14*@height/16-1) then answer1_color = @selected_color
			when (14*@height/16)...(15*@height/16-1) then answer2_color = @selected_color
			when (15*@height/16)...(16*@height/16-1) then answer3_color = @selected_color
		end
		$window.fill_rect(@question_board, @qb_color, ZOrder::POPUP)
		$window.fill_rect(@answer_board1, answer1_color, ZOrder::POPUP)
		$window.fill_rect(@answer_board2, answer2_color, ZOrder::POPUP)
		$window.fill_rect(@answer_board3, answer3_color, ZOrder::POPUP)
		
		@q_text.draw; @a1_text.draw; @a2_text.draw; @a3_text.draw;
		
	end
	
	def quit_conversation
		pop_game_state
	end
	
end

class Popup < Chingu::GameState
	def initialize(line, x, y, opts={})
		super opts
		@line = line
		@tc =  Gosu::Color::WHITE
		@bc = Gosu::Color.new(220, 0,0,0)
		@board = Chingu::Rect.new(100,200,200,100)
		@text = Chingu::Text.new(@line, x: 100, y: 200, color: @tc)
		self.input = {:mouse_left => :click}
	end
	
	def click
		pop_game_state
		puts "done"
	end
	
	def draw
		previous_game_state.draw
		$window.fill_rect(@board, @bc)
		@text.draw
	end
		
		
end

class Dialog
	attr_accessor :question, :answers, :next_dialog
	
	def initialize (question, answers, next_dialog=nil)
		@question = question
		@answers = answers
		@next_dialog = next_dialog
	end
end


