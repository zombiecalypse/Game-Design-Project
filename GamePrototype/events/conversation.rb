require 'chingu'
module Events
  class Conversation
    attr_reader :lines
    def initialize opts={}
      @lines = opts[:lines]
    end

    def render
      puts @lines
    end

    def == other
      return false if not other.respond_to? :lines
      lines == other.lines
    end
  end
end
