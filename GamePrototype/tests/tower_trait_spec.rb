require_relative '../object_traits/tower.rb'
require 'rubygems'
require 'rspec'

describe Chingu::Traits::Tower do
  before :each do
    @game = Chingu::Window.new
    @projectile_class = Class.new(Chingu::Traits::Tower::Projectile) do
      def on_hit player
        player.harm 20
      end
    end
    @enemy_class = Class.new(Chingu::GameObject) do
      trait :tower, projectile: @projectile_class
    end

    @tower = @enemy_class.new x: 50, y: 50
    @player = Objects::Player.new x: 100, y: 80
  end

  after :each do
    @game.close
  end

  it "should shoot at the player when possible" 

  it "should not shoot at the player if player not visible"

  it "should hit the player, if they don't move"

  it "should harm the player when its projectile hits"
end
