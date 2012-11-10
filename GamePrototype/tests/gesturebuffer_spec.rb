require_relative '../interface/gesture_controller'

require 'rspec'

module Interface
  describe GestureBuffer do
    before(:each) do
      @window = double()
      @buffer = GestureBuffer.new @window
    end

    def unclear
      (50..200).collect { rand*50 - 25 }
    end


    it "should recognize a perfect line" do
      @window.should_receive(:mouse_x).at_least(100).times.and_return(50)
      @window.should_receive(:mouse_y).and_return(*(50..200))
      (50..200).each {@buffer.dot}
      @buffer.read.should be(:down)
    end

    it "should recognize an imperfect line" do
      @window.should_receive(:mouse_y).and_return(*unclear)
      @window.should_receive(:mouse_x).and_return(*(50..200))
      (50..200).each {@buffer.dot}
      @buffer.read.should be(:right)
    end

    it "should recognize a perfect arc" do
      @window\
        .should_receive(:mouse_x)\
        .and_return(*(\
                      (0..180)\
                        .collect {|x| 200 + 100*Math::cos(x*Math::PI/180)}))
      @window\
        .should_receive(:mouse_y)\
        .and_return(*(\
                      (0..180)\
                        .collect {|x| 200 - 100*Math::sin(x*Math::PI/180)}))
      (0..180).each {@buffer.dot}
      @buffer.read.should be(:top_arc)
    end

    it "should recognize an imperfect arc" do
      imperfect_x = (0..180)\
        .collect {|x| 200 + 100*Math::cos(x*Math::PI/180)}\
        .zip((0..180).collect{ 30*rand - 15})\
        .collect {|x,y| x+y}
      imperfect_y = (0..180)\
        .collect {|x| 200 - 100*Math::sin(x*Math::PI/180)}\
        .zip((0..180).collect{ 30*rand - 15})\
        .collect {|y,e| y+e}
      @window.should_receive(:mouse_x).and_return(*imperfect_x)
      @window.should_receive(:mouse_y).and_return(*imperfect_y)
      (0..180).each {@buffer.dot}
      @buffer.read.should be(:top_arc)
    end
  end
end
