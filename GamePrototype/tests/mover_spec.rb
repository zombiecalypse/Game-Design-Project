require 'bundler'
Bundler.require

require_relative '../object_traits/mover'
require_relative '../helpers/dummy_image'
require_relative './test_helpers'

class BasicMover < Chingu::GameObject
  trait :mover, speed: 5
  attr_accessor :obstacles
  blocked_if {|x,y| obstacles.any? { |e| e.collide_point? x,y } if obstacles}
end
describe Chingu::Traits::Mover do
  before :each do
    @game = Chingu::Window.new
    Gosu::Image.autoload_dirs = [relative('media')]
    @mover = BasicMover.new x: 50, y: 0, image: Gosu::Image['dummy.png']
  end
  after :each do
    @mover.destroy if @mover
    @game.close
  end

  context "when moving at enemy" do
    before :each do
      @mover.move_to P[50,100]
    end
    it "moves toward its goal in straight line, if possible" do
      30.times { @mover.update_trait }
      @mover.x.should be_within(10).of(50)
      @mover.y.should be_within(10).of(100)
    end

    it "is blocked by obstacles" do
      @mover.obstacles = [ Chingu::Rect.new(0,40, 100, 20) ]
      30.times { @mover.update_trait }
      @mover.y.should_not be_within(10).of(100)
    end

    it "moves around obstacles" do
      @mover.obstacles = [ Chingu::Rect.new(30,40, 40, 20) ]
      30.times { @mover.update_trait }
      @mover.y.should_not be_within(10).of(100)
      60.times { @mover.update_trait }
      @mover.y.should be_within(10).of(100)
    end
  end

  context "when moving away from enemy" do
    it "takes a favourite distance" do
      @mover.keep_distance P[50,100], 30
      30.times { @mover.update_trait }
      @mover.y.should be_within(10).of(70)
    end

    it "moves away from enemy" do
      @mover.y = 5
      @mover.move_away_from P[50,0]
      30.times { @mover.update_trait }
      @mover.y.should be_within(10).of(155)
    end

    it "moves around obstacles when fleeing" do
      @mover.obstacles = [ Chingu::Rect.new(30,40, 40, 20) ]
      @mover.y = 5
      @mover.move_away_from P[50,0]
      60.times { @mover.update_trait }
      @mover.y.should_not be_within(100).of(5)
    end
  end
end
