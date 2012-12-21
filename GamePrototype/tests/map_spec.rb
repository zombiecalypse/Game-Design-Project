require_relative '../levels/map'
require 'rubygems'
require 'rspec'
require 'chingu'
require 'gosu'
require 'logger'

def relative(path)
  File.join(File.expand_path(File.dirname(__FILE__)), path)
end

# Oh I f*ing love rspec
include Levels
describe Map do
  before :all  do
    Gosu::Image.autoload_dirs << relative('media/maps')
  end
  before :each do
    @game = Chingu::Window.new
  end

  after :each do
    @game.close
  end

  it "should be able to add image" do
    map = Map.create do
      at(0,0).map("test_level_map.png", "test_level_mask.png")
    end

    map.should be_blocked(25,125) 
    map.should_not be_blocked(300,200)
  end

  it "should take multiple images" do
    map = Map.create do
      at(0,0).map("test_level_map.png", "test_level_mask.png")
      
      at(100,100).map("test_level_map.png", "test_level_mask.png")
    end

    map.should be_blocked(25,125) 
    map.should be_blocked(125,225)
    map.should_not be_blocked(325,425)
  end

  it "can define startpoints" do
    map = Map.create do
      at(100,50).startpoint :teleport1
      at(200,500).startpoint :teleport2
    end

    map.startpoints[:teleport1].should eq [100, 50]
    map.startpoints[:teleport2].should eq [200,500]
  end

  it "can define objects at certain positions" do
    map = Map.create do
      at(50,500).object :spider
      at(10,0).object :spider

      at(100,30).object :boar
    end

    map.objects[:spider].size.should be 2
    map.objects[:spider].should include [50,500]
    map.objects[:spider].should include [10,0]
  end

  it "can define event zones" do
    map = Map.create do
      at(0,0).map("test_mask.png", "test_mask.png")

      define :cut_scene1, rgb(120,10,230)
      define :cut_scene2, rgb(130,10,230)
    end

    map.at(200,200).should eq :cut_scene1
    map.at(100,200).should eq nil
  end
end
