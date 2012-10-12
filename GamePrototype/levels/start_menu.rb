require 'rubygems'
require 'chingu'
require 'gosu'

require_relative 'level'

module Levels
  class StartMenu < Chingu::GameState
    def initialize(opts={})
      super opts
      @menu= Chingu::SimpleMenu.create(menu_items: {
        "Start" => TestLevel,
        "Exit"  => :exit
      })
    end
  end
end
