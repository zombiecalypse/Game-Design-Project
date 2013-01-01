require_relative '../levels/base_level'
require_relative 'test_helpers'

include Levels
describe Level do
  before :all do
    Map::MapResource.autoload_dirs << relative('media', 'maps')
  end

  before :each do
    @game = Chingu::Window.new
    @camera = Chingu::GameObject.new
  end

  after :each do
    @game.close
  end

  context "in the definition phase" do
    it "can define a map" do
      level_class = Class.new(Level) do
        map do
          at(0,0).map("test_level_map.png", "test_level_mask.png")
        end
      end

      level_class.new(camera: @camera).map.should_not be_nil
    end

    it "can bind events to zones"

    it "can have a tune"

    it "can define object callbacks"
  end

  context "when defined" do
    it "should have a map"

    it "should not be modifiable"

    it "should trigger events, when the player hits a zone"

    it "should have created objects for the map points"

    it "should block player from leaving the outer frame"
  end

end
