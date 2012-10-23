module Events
  class Conversation
    trait :timer
    def initialize opts={}
      super opts
      @lines = opts[:lines]
    end

    def render
      puts @lines
    end
  end
end
