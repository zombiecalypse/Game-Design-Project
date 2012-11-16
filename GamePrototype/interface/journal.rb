require 'rubygems'
require 'chingu'
require 'gosu'

require_relative '../menu/menu'

module Interface
  class Journal 
    class Opened < Chingu::GameState
      def initialize(opts={})
        super
        @bg = Gosu::Color::BLACK
        @menu = Levels::Menu.create(menu_items: opts[:journal].pages)
        self.input = {
          esc: lambda {$window.pop_game_state}
        }
      end

      include Chingu::Helpers::GFX

      def draw
        fill(@bg)
        super
      end
    end
    class Page
      attr_reader :title

      def initialize(opts={})
        @title = opts[:title]
        @text = opts[:text]
      end

      class State < Chingu::GameState
        def initialize(opts = {})
          super
          @bg = Gosu::Color::BLACK
          @title = Chingu::Text.new(opts[:title], x: 50, y: 50, size: 40, max_width: 400, align: :center)
          @text = Chingu::Text.new(opts[:text],  x: 50, y: 100, max_width: 400, align: :left)
          self.input = {
            esc: lambda {$window.pop_game_state}
          }
        end
        include Chingu::Helpers::GFX

        def draw
          super
          fill(@bg, ZOrder::BACKGROUND)
          @title.draw
          @text.draw
        end
      end

      def show
        $window.push_game_state(State.new(title: @title, text: @text))
      end
    end

    def initialize(opts={})
      @current_pages = opts[:pages] || []
    end

    def add_page(title, text)
      @current_pages << Page.new(title: title, text: text)
    end

    def pages
      hash = {}
      @current_pages.each do |page|
        hash[page.title] = lambda { page.show }
      end
      hash
    end

    def show
      $window.push_game_state(Opened.new(journal: self))
    end
  end
end
