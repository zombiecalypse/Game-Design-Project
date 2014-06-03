require 'bundler'
Bundler.require
require 'json'

require_relative 'map'
require_relative '../helpers/logging'
require_relative '../interface/z_orders'
require_relative '../helpers/dist'

module Levels
  class Tilemap < Map
    include Chingu::NamedResource
    self.autoload_dirs = [File.join('media', 'maps')]

    def self.autoload name
      path = find_file(name)
      raise "No such file #{name} in any of #{self.autoload_dirs}" unless path
      self.new path
    end


    # TODO: Load JSON
    #
    # Tiled JSON export format:
    #   `height`, `width` in cells
    #   `tileheight`, `tilewidth` in pixel
    #   a list of `layers` from bottom to top:
    #    name
    #    can be either tilelayer:
    #      a flat list of cell elements `data` 
    #       0 means empty
    #       index in tileset
    #   or a objectlayer
    #     a list of `objects`
    #       can either be a plain object 
    #         `x`, `y` in pixel
    #         `type`
    #       or a polygon:
    #         `x`, `y` offsets in pixel
    #         `polygon` - a list of points
    #           `x`, `y` in pixel
    #   a list of `tilesets`
    #     `image` that gives the tile map

    # I define *our* level format as follows:
    #   a tilelayer "Ground", which is below the player
    #   a tilelayer "Walls", that player should not be able to enter (Z same as
    #     player) the elements might or might not be used for collisions
    #   an objectlayer "Movement" containing polygons, that define, where the player
    #     *can* move. These intersect, a point is visitable, if at least one
    #     polygon contains the point
    #   an objectlayer "Events" containing events. Later this defines where and
    #     how events are triggered.
    #   an objectlayer "Enemies", that contains objects with types corresponding
    #     to the enemy types.
    #
    #
    #
    # OMG we have a performance problem with the maps if sufficiently huge! I'm
    # so exited! Do *all* the quad-trees!
    #
    # Findings so far: 
    #  * bottle-necks are:
    #     - drawing of tiles, which could for the most part be avoided
    #     - loading of the tiles is slow, but does not impair the game in any
    #       way
    #     - The garbage collector seems to struggle with something.
    # * solutions:
    #     - Quad-tree for drawing and updating
    #     - finding out, what objects are created all the time only to be
    #       destroyed.
    include Helpers::DoesLogging[level: Logger::DEBUG]
    attr_reader :width_in_tiles, :height_in_tiles, :tilewidth, :tileheight

    attr_reader :tilesets, :ground_tiles, :wall_tiles
    attr_reader :movement_polygons, :events, :objects

    attr_accessor :viewport

    def initialize filename
      # super if false # not compartible
      map = open(filename) {|f| JSON.load f.read}
      @width_in_tiles    = map["width"]
      @height_in_tiles   = map["height"]
      @tilewidth         = map['tilewidth']  || 32
      @tileheight        = map['tileheight'] || 32
      @events            = []
      @movement_polygons = []
      @startpoints       = {}
      @objects           = {}
      @ground_tiles      = []
      @wall_tiles        = []
      map['tilesets'].each {|e| load_tile_properties e['tileproperties']}
      map['tilesets'].each {|e| load_tileset e}
      load_layers  map['layers']
    end

    def vp_width
      @vp_width ||= ($window.width/@tilewidth).to_i
    end

    def vp_height
      @vp_height ||= ($window.height/@tileheight).to_i
    end

    def load_tile_properties props
      @tile_properties ||= {}
      return unless props
      props.each_pair do |index, properties|
        @tile_properties[index.to_i] = parse_properties properties
      end
    end

    def parse_properties properties
      hash = {}
      properties.each_pair do |key, val|
        key = key.to_sym
        hash[key] =  integer_property?(key) ? val.to_i : val
      end
      hash
    end

    def integer_property? key
      key == :zorder
    end

    def load_tileset properties
      image_path = properties['image']
      @tileset ||= []
      begin
        @tileset.concat Gosu::Image.load_tiles($window, Gosu::Image[image_path], properties['tilewidth'], properties['tileheight'], true)
      rescue Exception => e
        log_error { "Couldn't load #{image_path}, out of #{Gosu::Image.autoload_dirs}" }
        throw e
      end
    end

    def draw
      @viewport.apply do 
        draw_smartly
      end
    end

    def xi; @viewport.x.to_i/@tilewidth; end

    def yi; @viewport.y.to_i/@tileheight; end

    def coord col,row
      row * @width_in_tiles + col
    end

    # Heavily optimized code
    def draw_layer layer
      bot_row = yi +  3*vp_height/2
      rh_col  = xi +  3*vp_width/2
      col_min = xi -    vp_width/2
      layer.each do |layer|
        row =   yi -    vp_height/2
        col = col_min
        while row < bot_row
          layer[coord(col,row)].draw if layer[coord(col,row)]
          col += 1
          if col >= rh_col
            col = col_min
            row += 1
          end
        end
      end
    end

    # Somewhat quick, but not quick enough
    def draw_smartly
      draw_layer @ground_tiles
      draw_layer @wall_tiles
    end


    def destroy
      (@ground_tiles.values + @wall_tiles.values).each {|e| e.destroy rescue nil}
    end

    def load_layers layers
      layers.each do |m|
        case m['name']
        when /ground/i
          load_ground m
        when /walls/i
          load_walls m
        when /movement/i
          load_movement m
        when /startpoints/i
          load_startpoints m
        when /events/i
          load_events m
        when /objects/i
          load_objects m
        when /enemies/i
          load_objects m
        end
      end
    end

    def enemies; @objects; end

    def tile_properties index
      @tile_properties[index] || {}
    end

    def load_tiles data, v, z
      list = []
      enum = data.to_enum
      (0...@height_in_tiles).each do |yi|
        (0...@width_in_tiles).each do |xi|
          index = enum.next - 1
          unless index == -1
            prop = tile_properties index
            list[coord(xi,yi)] = Tile.new(image: @tileset[index], zorder: prop[:zorder] || z, x: xi*@tilewidth, y: yi*@tileheight, hidden: (not v))
          end
        end
      end
      list 
    end

    def load_ground layer
      @ground_tiles << load_tiles(layer['data'], layer['visible'], ZOrder::MAP)
      log_debug {"loaded #{@ground_tiles.size} ground tiles"}
    end

    def load_walls layer
      @wall_tiles << load_tiles(layer['data'], layer['visible'], ZOrder::PLAYER)
      log_debug {"loaded #{@wall_tiles.size} wall tiles"}
    end

    def load_movement layer
      @movement_polygons = layer['objects'].collect do |o|
        next unless o['polygon']
          Polygon.new o['x'], o['y'], o['polygon']
      end
      log_debug {"loaded #{@movement_polygons.size} movement zones"}
    end

    def load_startpoints layer
      layer['objects'].each {|o| @startpoints[o['name'].downcase.to_sym] = [o['x'],o['y']]}
      log_debug {"loaded #{@startpoints.size} start points"}
      log_debug { "\t"+@startpoints.keys.join(" ") }

    end

    def load_events layer
      @events = layer['objects'].collect do |o|
        {name: o['name'].downcase.to_sym, poly: Polygon.new(o['x'], o['y'], o['polygon'])}
      end
      log_debug {"loaded #{@events.size} events"}
    end

    def load_objects layer
      layer['objects'].each do |o|
        type = o['type'].downcase.to_sym
        @objects[type] ||= []
        @objects[type] << [o['x'],o['y']]
      end
      log_debug {"loaded #{@objects.keys.size} types of enemies, to a total of #{@objects.values.inject(0){|x,y| x+y.size}}"}
    end

    def width
      @width_in_tiles * @tilewidth
    end

    def height
      @height_in_tiles * @tileheight
    end

    def blocked? x,y
      not @movement_polygons.any? {|p| p.collide_point? x,y}
    end

    def at(x,y)
      event = @events.detect {|e| e[:poly].collide_point?(x,y)}
      event[:name] if event
    end

    def startpoints
      @startpoints
    end

    class Tile < Chingu::GameObject
      attr_accessor :hidden
      def initialize(opts={})
        super opts
        @hidden = opts[:hidden] || false
        pause
      end

      def rect
        Chingu::Rect.new(x,y, width, height)
      end
      
      def draw
        @image.draw_rot(@x + @image.width/2, @y - @image.height/2 + 32, @zorder, @angle, @center_x, @center_y, @factor_x, @factor_y, @color, @mode)  if @image and not @hidden
      end
    end

    class Polygon
      attr_reader :bounding_box
      def initialize off_x, off_y, list
        @points = list.collect {|p| P[off_x+p['x'],off_y + p['y']]}
        build_bounding_box
      end

      def collide_point? x,y
        return false unless @bounding_box.collide_point? x,y
        point = P[x,y]

        contains_point = false
        adjacent_points = @points.zip(@points.rotate 1)
        cuts = adjacent_points.select do |from, to|
          next unless point_is_between_the_ys_of_the_line_segment?(point, from, to)
          ray_crosses_through_line_segment?(point, from, to)
        end
        cuts.size.odd?
      end

      private

      def point_is_between_the_ys_of_the_line_segment?(point, from, to)
        return true if to.y <= point.y and point.y < from.y
        return true if from.y <= point.y and point.y < to.y
      end

      def ray_crosses_through_line_segment?(point, from, to)
        (point.x < (from.x - to.x) * (point.y - to.y) / 
         (from.y - to.y) + to.x) rescue false
      end

      def build_bounding_box
        minx = @points.collect(&:x).min
        miny = @points.collect(&:y).min
        maxx = @points.collect(&:x).max
        maxy = @points.collect(&:y).max
        @bounding_box = Chingu::Rect.new minx, miny, maxx-minx, maxy-miny
      end

      def rect; @bounding_box; end
    end
  end
end
