require_relative '../game_objects/spider'
require_relative '../game_objects/simple_tower.rb'
module Enemies
  def self.all; @all; end
  def self.enemy x
    @all ||= []
    @all << x
  end

  enemy Objects::Spider
  enemy Objects::SimpleTower
end
