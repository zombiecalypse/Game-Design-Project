require_relative '../object_traits/state_ai'
require 'rubygems'
require 'rspec'
require 'chingu'
require 'gosu'

describe Chingu::Traits::StateAi  do
  before :each do
    @game = Chingu::Window.new
    @ai = Class.new(Chingu::GameObject) do
      trait :state_ai

      attr_reader :did_start, :did_other

      when_in(:start) do
        @did_start = true
        self.state = :other
      end

      when_in(:other) do
        @did_other = true
        self.state = :weird
      end
    end
    @instance = @ai.new
  end

  after :each do
    @instance.destroy
    @game.close
  end

  it "is in :start state per default" do
    @instance.state.should be :start
  end

  it "executes the current state block" do
    @instance.update_trait
    @instance.did_start.should be true
  end

  it "can switch states to change its behaviour" do
    @instance.update_trait
    @instance.state.should be :other
    @instance.update_trait
    @instance.did_other.should be true
    @instance.state.should be :weird
  end

  it "does nothing, if it is not in a valid state" do
    @instance.update_trait
    @instance.update_trait
    @instance.update_trait
    @instance.state.should be :weird
  end
end
