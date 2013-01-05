require 'bundler'
Bundler.require

require_relative '../object_traits/mover'
require_relative '../helpers/dummy_image'
require_relative './test_helpers'

class BasicMover < Chingu::GameObject
  trait :mover, speed: 10
  attr_accessor :obstacles
  blocked_if {|x,y| obstacles.any? { |e| e.collide_point? x,y } if obstacles}
end
describe Chingu::Traits::Mover do
  before :each do
    @game = Chingu::Window.new
    Gosu::Image.autoload_dirs = [relative('media')]
    @mover = BasicMover.new x: 0, y: 0, image: Gosu::Image['dummy.png']
  end
  after :each do
    @mover.destroy if @mover
    @game.close
  end

  context "when moving at enemy" do
    before :each do
      @mover.move_to P[100,100]
    end
    it "is blocked by obstacles" do
      @mover.obstacles = [ Chingu::Rect.new(-50,40, 100, 20) ]
      15.times { @mover.update_trait }
      @mover.x.should_not be_within(10).of(100)
      @mover.y.should_not be_within(10).of(100)
    end
    it "moves toward its goal in straight line, if possible" do
      15.times { @mover.update_trait }
      @mover.x.should be_within(10).of(100)
      @mover.y.should be_within(10).of(100)
    end

    it "moves around obstacles"
  end

  context "when moving away from enemy" do
    it "takes a favourite distance"

    it "moves away from enemy"

    it "moves around obstacles when fleeing"
  end

  it
end
