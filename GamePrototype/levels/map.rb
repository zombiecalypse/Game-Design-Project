require 'texplay'
module Levels
  # TODO 
  #   1) Map will newly get multiple images as parameter, that lay 
  #      out the whole map.
  #   2) Map will get event-colours
  #   3) Map will also get a cool syntax, because hell yeah, syntax.
  #
  class Map < Chingu::GameObject
    attr_reader :objects, :startpoints
    def initialize opts={}, &block
      super(opts)
      @objects     = {}
      @startpoints = {}
      @events      = {}
      @images      = []
      @masks       = []
      instance_exec &block
      @finished = true
    end

    # GOAL:

    # Map.new do
    #   at(0,0).map("level1_map.png", 'level1_mask.png')
    #  
    #   define :cut_scene1, rgb(0.2, 0.1, 0.9)
    #   
    #   at(100,100).startpoint :teleport1
    #  
    #   at(300,200).object :spider
    #   at(350,200).object :spider
    # end
    #
    # This works, except for behaviour

    def at(x,y)
      unless @finished
        AtBuilder.new x, y, self
      else
        @events[mask_colour(x,y).to_s] 
      end
    end

    def mask_colour x, y
      mask=@masks.detect do |e| 
        (x-e.x).between?(0, e.image.width) and (y-e.y).between?(0, e.image.height)
      end
      mask.image.get_pixel(x-mask.x, y-mask.y, :color_mode => :gosu) if mask
    end

    def rgb(r,g,b)
      Gosu::Color.new(r,g,b)
    end

    def blocked? x,y
      @masks.any? {|e| is_wall? e.image.get_pixel(x,y) rescue false}
    end

    def is_wall? pixel
      r,g,b,a = pixel
      r < 0.1 and g < 0.1 and b < 0.1 and a > 0.99
    end

    def define name, colour
      add_event_definition name, colour
    end

    def destroy
      (@masks + @images).each {|g| g.destroy}
      super
    end

    def editable
      raise "Not editable" if @finished
    end

    def add_event_definition name, colour
      editable
      @events[colour.to_s] = name
    end

    class MaskPatch < Chingu::GameObject
    end

    class ImagePatch < Chingu::GameObject
    end

    class MapResource < Gosu::Image
      include Chingu::NamedResource
      autoload_dirs << 'media/maps'
    end

    def add_mask_at(x,y, img)
      editable
      mask=MaskPatch.new(image: MapResource[img], center: 0, x: x, y: y)
      mask.center=0
      @masks <<  mask
    end

    def add_image_at(x,y,img)
      editable
      img = ImagePatch.create(image: MapResource[img], center: 0, x: x, y: y)
      img.center=0
      @images << img
    end

    def add_startpoint_at(x,y,name)
      editable
      raise "Name #{name} is already taken" if @startpoints[name]
      @startpoints[name] = [x,y]
    end

    def add_object_at(x, y, name)
      editable
      @objects[name] ||= []
      @objects[name] << [x,y]
    end

    class AtBuilder
      def initialize x,y, parent
        @x = x
        @y = y
        @parent = parent
      end

      def map image, mask=nil
        @parent.add_mask_at(@x,@y, mask || image)
        @parent.add_image_at(@x,@y, image)
      end

      def startpoint name
        @parent.add_startpoint_at(@x, @y, name)
      end

      def object name
        @parent.add_object_at(@x, @y, name)
      end
    end
  end
end