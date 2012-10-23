require_relative '../events/dsl'
require_relative '../events/conversation'
require 'rspec'

describe Dsl::Event do
  include Dsl
  it "has `on_hit` to automatically run on box collision" do
    event = Dsl::Event.new(debug: true) do |evt|
      evt.on_hit do
        show_popup("Cure for cancer found")
      end
    end
    event.hit.should eq([Events::Conversation.new(lines: "Cure for cancer found")])
  end

  it "has `on_activate` to run on box collision when clicked" do
    event = Dsl::Event.new(debug: true) do |evt|
      evt.on_activate do
        show_popup("Cure for cancer found")
      end
    end
    event.activate.should eq([Events::Conversation.new(lines: "Cure for cancer found")])
  end

  it "has `automatically` to run at the beginning of the scene" do
    event = Dsl::Event.new(debug: true) do |evt|
      evt.automatically do
        show_popup("Cure for cancer found")
      end
    end
    event.enter_scene.should eq([Events::Conversation.new(lines: "Cure for cancer found")])
  end

  it "allows simple text popups" do
    event = Dsl::Event.new(debug: true) do |evt|
      evt.on_hit do
        show_popup("Cure for cancer found")
      end
    end
    event.hit.should eq([Events::Conversation.new(lines: "Cure for cancer found")])
  end

  it "allows multiple text popups" do
    event = Dsl::Event.new(debug: true) do |evt|
      evt.on_hit do
        show_popup("Cure for cancer found")
        show_popup("requires only 3 sacrificed unicorns")
      end
    end
    event.hit.should eq([Events::Conversation.new(lines: "Cure for cancer found"), Events::Conversation.new(lines: "requires only 3 sacrificed unicorns")])
  end

  it "should by default run everything over and over" do
    event = Dsl::Event.new(debug: true) do |evt|
      evt.on_hit do
        show_popup("Cure for cancer found")
      end
    end
    event.hit.should eq([Events::Conversation.new(lines: "Cure for cancer found")])
    event.hit.should eq([Events::Conversation.new(lines: "Cure for cancer found")])
  end

  it "should have the option to run only once" do
    event = Dsl::Event.new(debug: true, once: true) do |evt|
      evt.on_hit do
        show_popup("Cure for cancer found")
      end
    end
    event.hit.should eq([Events::Conversation.new(lines: "Cure for cancer found")])
    event.hit.should eq([])
  end

  it "should by default only run automatically started events once" do
    event = Dsl::Event.new(debug: true) do |evt|
      evt.automatically do
        show_popup("Cure for cancer found")
      end
    end

    event.enter_scene.should eq([Events::Conversation.new(lines: "Cure for cancer found")])
    event.enter_scene.should eq([])
  end

  it "allows to code sequential events" do
    event = Dsl::Event.new(debug: true, once: true) do |evt|
      evt.on_hit do
        show_popup("Cure for cancer found")
      end
      evt.on_hit do
        show_popup("requires only 3 sacrificed unicorns")
      end
    end
    event.hit.should eq([Events::Conversation.new(lines: "Cure for cancer found")])
    event.hit.should eq([Events::Conversation.new(lines: "requires only 3 sacrificed unicorns")])
  end
end
