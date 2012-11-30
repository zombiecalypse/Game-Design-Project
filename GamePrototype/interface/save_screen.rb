require 'singleton'
require 'pathname'
module Interface
  class LoadScreen < Chingu::GameState
    include Chingu::Helpers::GFX

    def draw
      fill(Colors::BACKGROUND, ZOrder::BACKGROUND)
      super
    end

    def initialize(opts = {}) 
      super
      @menu = Levels::Menu.create(menu_items: SaveDatabase.instance.loads)
      self.input = {
        esc: lambda {$window.pop_game_state}
      }
    end
  end

  class SaveScreen < Chingu::GameState
    include Chingu::Helpers::GFX

    def draw
      fill(Colors::BACKGROUND, ZOrder::BACKGROUND)
      super
    end

    def initialize(opts = {}) 
      super
      @menu = Levels::Menu.create(menu_items: SaveDatabase.instance.saves)
      self.input = {
        esc: lambda {$window.pop_game_state}
      }
    end
  end
  
  class SaveDatabase
    include Singleton
    class Save
      attr_accessor :name
      def self.build(name, &block)
        new = self.new name
        block.call new
        SaveDatabase.instance << new
      end

      def self.new_action
        lambda { create }
      end

      def self.create
        puts "NEW!"
        # TODO generate new ID and collect all data
      end

      def load_action
        lambda { load }
      end

      def load
        puts "Loading #{name}" 
      end
    end

    def initialize(file=File::join(Dir::home,'.anura.saves'))
      @path = ::Pathname.new(file)
      if @path.exist?
        @saves = YAML::load(file)
      else
        @saves = []
      end
    end

    def << save
      @saves << save
      @path.open { |f| f.write YAML::dump(@saves) }
    end

    def loads
      hash = {}
      @saves.each {|e| hash[e.name] = e.load_action}
      hash["Exit"] = lambda {$window.pop_game_state}
      hash
    end

    def saves
      {
        "New" => Save.new_action,
        "Exit" => lambda {$window.pop_game_state}
      }
    end
  end
end
