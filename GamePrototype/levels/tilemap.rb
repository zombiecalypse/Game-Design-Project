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
    include Modularity::Does
    does 'helpers/logging'
    attr_reader :width_in_tiles, :height_in_tiles, :tilewidth, :tileheight

    attr_reader :tileset, :ground_tiles, :wall_tiles
    attr_reader :movement_polygons, :events, :objects

    def initialize filename
      # super if false # not compartible
      map = open(filename) {|f| JSON.load f.read}
      @width_in_tiles = map["width"]
      @height_in_tiles = map["height"]
      @tilewidth = map['tilewidth'] || 32
      @tileheight = map['tileheight'] || 32
      load_tileset map['tilesets'].first['image']
      load_layers map['layers']
    end

    def load_tileset image_path
      begin
        @tileset = Chingu::Animation.new image: Gosu::Image[image_path], size: [@tilewidth, @tileheight]
      rescue Exception => e
        log_error { "Couldn't load #{image_path}, out of #{Gosu::Image.autoload_dirs}" }
        throw e
      end
    end

    def destroy
      (@ground_tiles + @wall_tiles).each {|e| e.destroy rescue nil}
    end

    def load_layers layers
      layers
        .select {|m| m['name'] =~ /ground/i}
        .each   {|m| load_ground m}
      layers
        .select {|m| m['name'] =~ /walls/i}
        .each   {|m| load_walls m}
      layers
        .select {|m| m['name'] =~ /movement/i}
        .each   {|m| load_movement m}
      layers
        .select {|m| m['name'] =~ /startpoints/i}
        .each   {|m| load_startpoints m}
      layers
        .select {|m| m['name'] =~ /events/i}
        .each   {|m| load_events m}
      layers
        .select {|m| m['name'] =~ /enemies/i or m['name'] =~ /objects/i}
        .each   {|m| load_objects m}
    end

    def enemies; @objects; end

    def load_tiles data, z
      arr = []
      enum = data.to_enum
      (0...@height_in_tiles).each do |yi|
        (0...@width_in_tiles).each do |xi|
          index = enum.next
          unless index == 0
            arr << Tile.create(image: @tileset[index - 1], zorder: z, x: xi*@tilewidth, y: yi*@tileheight)
          end
        end
      end
      arr 
    end

    def load_ground layer
      @ground_tiles = load_tiles layer['data'], ZOrder::MAP
      log_debug {"loaded #{@ground_tiles.size} ground tiles"}
    end

    def load_walls layer
      @wall_tiles = load_tiles layer['data'], ZOrder::PLAYER
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
      @startpoints = {}
      layer['objects'].each {|o| @startpoints[o['name'].downcase.to_sym] = [o['x'],o['y']]}
      log_debug {"loaded #{@startpoints.size} start points"}
      log_debug { @startpoints.keys.join(" ") }

    end

    def load_events layer
      @events = layer['objects'].collect do |o|
        {name: o['name'].downcase.to_sym, poly: Polygon.new(o['x'], o['y'], o['polygon'])}
      end
      log_debug {"loaded #{@events.size} events"}
    end

    def load_objects layer
      @objects = {}
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
      def rect
        Chingu::Rect.new(x,y, width, height)
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
