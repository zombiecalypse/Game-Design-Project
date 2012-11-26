require_relative '../interface/color_theme'
class Chingu::BasicGameObject
  def rect
    Chingu::Rect.new(self.x-self.width/2,self.y-self.height/2, self.width, self.height)
  end
end
module Levels
  class Menu < Chingu::BasicGameObject
    include Chingu::Helpers::InputClient
    attr_accessor :menu_items, :visible
    
    def initialize(options = {})
      super
      
      # @font_size = options.delete(:font_size) || 30
      @menu_items = options.delete(:menu_items)
      @x = options.delete(:x) || $window.width/2
      @y = options.delete(:y) || 0
      @spacing = options.delete(:spacing) || 100
      @items = []
      @visible = true
  
      y = @y
      menu_items.each do |key, value|
        item = if key.is_a? String
          Chingu::Text.new(key, {color: Colors::INACTIVE}.merge!(options.dup))
        elsif key.is_a? Image
          Chingu::GameObject.new(options.merge!(:image => key))
        elsif key.is_a? Chingu::GameObject
          key.options.merge!(options.dup)
          key
        end
        
        item.options[:on_select] = method(:on_select)
        item.options[:on_deselect] = method(:on_deselect)
        item.options[:action] = value
        
        item.rotation_center = :center_top
        item.x = @x
        item.y = y
        y += item.height + @spacing
        @items << item
      end      
      @selected = options[:selected] || 0
      step(0)
      
      self.input = {
        [:w, :up] => lambda{step(-1)}, 
        [:s, :down] => lambda{step(1)}, 
        [:return, :space, :mouse_left] => :select}
    end
    
    #
    # Moves selection within the menu. Can be called with negative or positive values. -1 and 1 makes most sense.
    #
    def step(value)
      selected.options[:on_deselect].call(selected)
      @selected += value
      @selected = @items.count-1  if @selected < 0
      @selected = 0               if @selected == @items.count
      selected.options[:on_select].call(selected)
    end
    
    def select
      dispatch_action(selected.options[:action], self.parent)
    end
            
    def selected
      @items[@selected]
    end
      
    def on_deselect(object)
      object.color = Colors::INACTIVE
    end
    
    def on_select(object)
      object.color = Colors::ACTIVE
    end
    
    def draw
      @items.each { |item| item.draw }
    end

    def item_selected(x,y)
      @items.each_with_index do |item, i|
        return i if item.rect.collide_point?(x,y)
      end
      nil
    end

    def update
      super
      x, y = $window.mouse_x, $window.mouse_y
      n_selected = item_selected(x,y)
      return unless n_selected and n_selected != @selected
      selected.options[:on_deselect].call(selected)
      @selected = n_selected
      selected.options[:on_select].call(selected)
    end
    
    private
    
    #
    # TODO - DRY this up with input dispatcher somehow 
    #
    def dispatch_action(action, object)
      case action
      when Symbol, String
        object.send(action)
      when Proc, Method
        action[]
      when Chingu::GameState
        game_state.push_game_state(action)
      when Class
        if action.ancestors.include?(Chingu::GameState)
          game_state.push_game_state(action)
        end
      else
        # TODO possibly raise an error? This ought to be handled when the input is specified in the first place.
      end
    end    

  end
end
