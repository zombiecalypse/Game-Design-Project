require_relative 'conversation'
module Dsl
  class Event
    def initialize opts={}, &block
      block.call(self)
      @once = opts[:once] || (not @on_scene.nil?)
    end

    def on_activate &block
      @on_activate ||= []
      @on_activate << block
    end

    def activate
      return [] unless @on_activate
      block, rest = @on_activate[0], @on_activate[1..-1]
      @on_activate = rest
      @on_activate << block unless @once
      run_block block
    end

    def on_hit &block
      @on_hit ||= []
      @on_hit << block
    end

    def hit
      return [] unless @on_hit
      block, rest = @on_hit[0], @on_hit[1..-1]
      @on_hit = rest
      @on_hit << block unless @once
      run_block block
    end

    def automatically &block
      @on_scene ||= []
      @on_scene << block
    end

    def enter_scene
      return [] unless @on_scene
      block, rest = @on_scene[0], @on_scene[1..-1]
      @on_scene = rest
      @on_scene << block unless @once
      run_block block
    end
    private
    def run_block block
      @buffer = []
      self.instance_eval &block if block
      [Events::Conversation.new(lines: @buffer)]
    end

    def show_popup(str)
      @buffer << Events::Popup.new(lines: str)
    end
  end
end
