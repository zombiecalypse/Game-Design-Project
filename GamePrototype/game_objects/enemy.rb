require 'rubygems'
require 'chingu'
require 'gosu'

module Objects
  class Enemy < Chingu::GameObject
    trait :bounding_box, debug: true
    trait :collision_detection
  end
end
