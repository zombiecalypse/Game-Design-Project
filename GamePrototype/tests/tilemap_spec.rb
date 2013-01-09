require_relative '../levels/tilemap'
require_relative 'test_helpers'

describe Levels::Tilemap do
  before :each do
    @game = Chingu::Window.new
    @tilemap = Levels::Tilemap.new relative('media', 'tiles_test.json')
    Gosu::Image.autoload_dirs = [relative('media')]
  end

  after :each do
    # @tilemap.destroy
    @game.close
  end
  context 'on loading' do

    it 'loads dimensions' do
      @tilemap.width_in_tiles.should be 15
      @tilemap.height_in_tiles.should be 16
      @tilemap.tilewidth.should be 32
      @tilemap.tileheight.should be 32
    end

    it 'loads tileset' do
      @tilemap.tileset.size.should eq [32,32]
    end

    it 'loads ground' do
      @tilemap.ground_tiles.size.should be 240
    end

    it 'loads walls' do
      @tilemap.wall_tiles.size.should be 90
    end

    it 'loads movement' do
      @tilemap.movement_polygons.size.should be 2
    end

    it 'loads events' do
      @tilemap.events.size.should be 1
    end

    it 'loads startpoints'

    it 'loads enemies' do
      @tilemap.enemies.values
        .inject(0) {|x,y| x+y.size}
        .should be 2
    end
  end

  context "implementing the map interface" do
    it "has dimensions" do
      @tilemap.width.should be 480
      @tilemap.height.should be 512
    end

    it "reports movement possibilities" do
      @tilemap.should_not be_blocked(150,150)
      @tilemap.should be_blocked(350, 400)
    end

    it "reports events" do
      @tilemap.at(480, 40).should be :evt1
    end

    it "defines enemies" do
      @tilemap.enemies[:bat].should eq [P[111,90],P[108,196]]
    end
  end
end
