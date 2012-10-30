require_relative '../object_traits/hp.rb'
require 'rubygems'
require 'rspec'

describe Chingu::Traits::Hp do
  before :each do
    @game = Chingu::Window.new
    @enemy_class = Class.new(Chingu::GameObject) do
      trait :hp, hp: 100
      attr_reader :harmed, :killed, :healed

      def on_harm x; @harmed = x end
      def on_kill; @killed = true end
      def on_heal x; @healed = x end
    end

    @enemy = @enemy_class.new
  end
  
  after :each do
    @game.close
  end

  it "should give a `hp` attribute" do
    @enemy.should respond_to :hp
    @enemy.should_not respond_to :hp=
    @enemy.hp.should eq(100)
  end

  it "should give a `max_hp` attribute, that is not settable" do
    @enemy.should respond_to :max_hp
    @enemy.should_not respond_to :max_hp=
    @enemy.max_hp.should eq(100)
  end

  it "should be able to create object at less than maximal hp" do
    harmed_enemy = @enemy_class.new hp_perc: 0.5
    harmed_enemy.hp.should eq 50
  end

  it "should reduce hp on harm" do
    @enemy.harm 40
    @enemy.hp.should eq 60

    expect { @enemy.harm(-10) }.to raise_error
  end

  it "should increase hp on heal" do
    @enemy.harm 40
    @enemy.heal 20
    @enemy.hp.should eq 80

    expect { @enemy.heal(-10) }.to raise_error
  end

  it "should not overheal" do
    @enemy.harm 40
    @enemy.heal 60
    @enemy.hp.should eq 100
  end

  it "should call `on_harm` when harm is done" do
    @enemy.harm 40
    @enemy.harmed.should eq 40

  end

  it "should call `on_kill` when the damage exceeds the hp" do
    @enemy.harm 120
    @enemy.killed.should eq true
  end

  it "should call `on_heal` when healing" do
    @enemy.harm 40
    @enemy.heal 10
    @enemy.healed.should eq 10

    @enemy.heal 40
    @enemy.healed.should eq 30
  end
end
