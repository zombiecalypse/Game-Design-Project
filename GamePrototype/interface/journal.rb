require 'rubygems'
require 'chingu'
require 'gosu'

require_relative '../menu/menu'

module Interface
  class Journal
    class Opened < Chingu::GameState
      def initialize(opts={})
        super
        @bg = Colors::BACKGROUND
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
      attr_reader :title, :text

      def initialize(opts={})
        @title = opts[:title]
        @text = opts[:text]
      end

      class State < Chingu::GameState
        def initialize(opts = {})
          super
          @title = Chingu::Text.new(opts[:title], x: 50, y: 50, size: 40, max_width: 400, align: :center, color: Colors::DESCRIPTION)
          @text = Chingu::Text.new(opts[:text],  x: 50, y: 100, max_width: 400, align: :left, color: Colors::DESCRIPTION)
          self.input = {
            [:esc, :enter] => lambda {$window.pop_game_state}
          }
        end
        include Chingu::Helpers::GFX

        def draw
          super
          fill(Colors::BACKGROUND, ZOrder::BACKGROUND)
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

    def extract_info
      hash = {}
      @current_pages.each do |page|
        hash[page.title] = page.text
      end
      hash
    end

    def set_to info
      @current_pages = []
      info.each_pair do |title, text|
        @current_pages << Page.new(title: title, text: text)
      end
    end
  end
end

def journal title, text
  the(PlayerDaemon).journal_page title, text
end
