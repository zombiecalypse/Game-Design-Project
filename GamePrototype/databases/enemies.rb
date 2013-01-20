require_relative '../game_objects/spider'
require_relative '../game_objects/bat'
require_relative '../game_objects/sniper'
require_relative '../game_objects/clockwork_soldier'
require_relative '../game_objects/simple_tower'
require_relative '../game_objects/weaver'
module Enemies
  def self.all; @all; end
  def self.enemy x
    @all ||= []
    @all << x
  end

  def self.boss x
    enemy x
  end

  enemy Objects::Spider
  enemy Objects::SimpleTower
  enemy Objects::Bat
  enemy Objects::Clockwork::Sniper
  enemy Objects::Clockwork::Soldier
  boss  Objects::Boss::Weaver
end
