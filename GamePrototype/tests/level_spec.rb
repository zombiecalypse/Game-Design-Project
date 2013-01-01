require_relative '../levels/base_level'
require_relative '../levels/map'
require_relative 'test_helpers'
require 'texplay'

include Levels
describe Level do
  before :all do
    @autoload = Map::MapResource.autoload_dirs.dup
    Map::MapResource.autoload_dirs = [relative('media', 'maps')]
    Gosu::Song.autoload_dirs = [relative('media')]
  end
  after :all do
    Map::MapResource.autoload_dirs = @autoload
  end

  before :each do
    @game = Chingu::Window.new
    @camera = Chingu::GameObject.new
  end

  after :each do
    @camera.destroy
    @game.close
  end

  after :all do
    TexPlay.refresh_cache_all
  end

  context "in the definition phase" do
    it "can define a map" do
      level_class = Class.new(Level) do
        map do
          at(0,0).map("test_level.png", "test_level.png")
        end
      end

      level = level_class.new(camera: @camera)
      level.map.should_not be_nil
    end

    it "can bind events to zones" do
      level_class = Class.new(Level) do
        map do
          link :dragon, rgb(120,120,0)
        end

        zone :dragon do
          :roar
        end
      end

      level = level_class.new(camera: @camera)
      level.zones[:dragon].call.should eq :roar
    end



    it "can have a tune" do
      level_class = Class.new(Level) do
        music "level_one.ogg"
      end
      level = level_class.new(camera: @camera)
      level.song_file.should eq "level_one.ogg"
      level.song.should_not be_nil
    end

    it "can define object callbacks" do
      level_class = Class.new(Level) do
        attr_reader :boar_on
        map do
          at(100,50).object(:boar)
        end

        on(:boar) do |x,y|
          @boar_on = [x,y]
        end
      end
      level = level_class.new(camera: @camera)
      level.boar_on.should eq [100,50]
    end
  end

  context "when defined" do
    it "should have a map"

    it "should not be modifiable"

    it "should trigger events, when the player hits a zone"

    it "should have created objects for the map points"

    it "should block player from leaving the outer frame"
  end

end
