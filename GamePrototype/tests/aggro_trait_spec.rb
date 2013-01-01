require 'rubygems'
require 'rspec'
require 'chingu'
require 'gosu'
require 'logger'

require_relative '../object_traits/shooter'
require_relative '../object_traits/aggro'

class Target < Chingu::GameObject
  trait :hp
end
class Enemy < Chingu::GameObject
  trait :aggro, observation_range: 300, range: 100, enemies: [Target], damage: 5

  attr_reader :attacked, :noticed

  on_attack do |x|
    @attacked ||= []
    @attacked << x
  end

  on_notice do |x|
    @noticed ||= []
    @noticed << x
  end

end

describe Chingu::Traits::Aggro do
  before :each do
    @game = Chingu::Window.new

    @tower = Enemy.create x: 50, y: 50
  end

  after :each do
    [@tower, @player].each {|e| e.destroy rescue nil}
    @game.close
  end

  it "should shoot at the player when possible" do
    @player = Target.create x: 100, y: 100
    @tower.update_trait

    @tower.attacked.should eq [@player]
  end

  it "should shoot at the player only after cooldown" do
    @player = Target.create x: 100, y: 100
    @tower.update_trait
    @tower.update_trait

    @tower.attacked.should eq [@player]

    @tower.cooldown!
    @tower.update_trait

    @tower.attacked.should eq [@player,@player]
  end

  it "should harm the player when attacking" do
    @player = Target.create x: 100, y: 100
    @tower.update_trait

    @player.hp.should_not eq @player.max_hp
  end

  it "should not shoot at the player if player not visible" do
    @player = Target.create x: 900, y: 190
    @tower.update_trait

    @player.hp.should eq @player.max_hp
  end

end
