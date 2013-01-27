require_relative 'weapons/pistol'
require_relative 'weapons/sword'

module Weapons
  def self.all; @all; end
  def self.default; @default; end
  def self.weapon name, x, opts={}
    @all ||= {}
    @all[name] = x
    @default = x if opts[:default]
  end

  weapon :sword, Sword
  weapon :pistol, Pistol, default: true
end
