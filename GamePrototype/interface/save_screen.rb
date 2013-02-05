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
      def initialize(name)
        @name = name
      end
      def self.build(name, &block)
        new = self.new name
        block.call new
        SaveDatabase.instance << new
      end

      def self.new_action
        lambda { create }
      end

      attr_accessor :player, :position, :journal, :level

      def self.create
        build Time.now.to_s do |save|
          save.player = the(PlayerDaemon).extract_player_info
          save.position = the(PlayerDaemon).extract_position
          save.journal = the(PlayerDaemon).journal.extract_info
          save.level = the(PlayerDaemon).level.extract_info
        end
      end

      def load_action
        lambda { load }
      end

      def load
        state = position[:level].new infos: level
        the(PlayerDaemon).teleport level: state, x: position[:x], y: position[:y]
        the(PlayerDaemon).set_player_info player
        the(PlayerDaemon).journal.set_to journal
      end
    end

    def initialize(file=File::join(Dir::home,'.anura.saves'))
      @path = ::Pathname.new(file)
      if @path.exist?
        @saves = @path.open { |f| YAML::load(f) }
      else
        @saves = []
      end
    end

    def << save
      @saves << save
      @path.open('w') { |f| f.write YAML::dump(@saves) }
    end

    def loads
      hash = {}
      @saves.each {|e| puts "#{e.name}"}
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
