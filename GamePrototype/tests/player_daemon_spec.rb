require_relative '../menu/player_daemon'
require 'rubygems'
require 'rspec'
require 'chingu'
require 'gosu'

describe PlayerDaemon do
  before :each do
    @daemon = PlayerDaemon.instance
    @level  = Class.new(Chingu::GameState)
    @game = Chingu::Window.new
    @player = double :player
    @new_player = double :new_player
    Objects::Player.stub(:create).and_return( @player, @new_player )
  end

  after :each do
    @game.close
    PlayerDaemon.reset_instance
  end

  context "just after creation" do
    it "should have a spellbook" do
      @daemon.spellbook.should be_a_kind_of Databases::SpellBook
    end

    it "should have a journal" do
      @daemon.journal.should be_a_kind_of Interface::Journal
    end

    it "should have a HUD" do
      @daemon.hud.should be_a_kind_of Interface::HudInterface
    end
  end

  context "before player is created" do
    it "should have no player" do
      @daemon.player.should eq nil
    end

    it "should create player by teleport" do
      @player.should_receive :input=
      @daemon.teleport level: @level, x: 100, y: 100
      @daemon.player.should eq @player
    end
  end

  context "after player is created" do
    before :each do
      $window.stub(current_game_state: @level)
      @player.should_receive :input=
      @daemon.teleport level: @level, x: 100, y: 100
      @new_level = Class.new(Chingu::GameState)
      @player.stub(extract_info: { hp: 100, dir: :down, speed: 3, vulnerability: 1 })
    end

    it "should have a player" do
      @daemon.player.should eq @player
    end

    it "should change coordinates on simple teleport" do
      @player.should_receive(:x=).with(200)
      @player.should_receive(:y=).with(300)
      @daemon.teleport x: 200, y: 300
    end

    it "should switch level on teleport" do
      @player.as_null_object
      $window.should_receive(:switch_game_state).with(@new_level)
      @new_player.should_receive :input=
      @daemon.teleport level: @new_level, x: 100, y: 100
    end

    it "should change destroy and recreate on teleport between levels" do
      @player.should_receive(:destroy)
      @new_player.should_receive :input=
      @daemon.teleport level: @new_level, x: 100, y: 100
      @daemon.player.should eq @new_player
    end
  end
end
