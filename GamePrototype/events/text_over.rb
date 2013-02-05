class TextOver < Chingu::GameObject
  trait :timer

  @@default_options = {
    max_width: 200
  }
  def initialize opts = {}
    super opts
    opts[:texts] ||= [opts[:text]]
    @texts = opts[:texts].collect {|t| Chingu::Text.new(t, opts)}
    @active = false
  end

  def activate
    @active ||= 0
    @current = @texts[@active]
    the(Objects::Player).every 2000 do
      @active += 1
      if @active >= @texts.size
        self.destroy
        @current = nil
      else
        @current = @texts[@active]
      end
    end
  end

  def draw
    return unless @active
    @current.draw if @current
  end
end

def textover txt
  the(PlayerDaemon).textover txt
end
