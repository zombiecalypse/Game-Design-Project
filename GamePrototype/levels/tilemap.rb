require 'bundler'
Bundler.require
require 'json'

require_relative 'map'
require_relative '../helpers/logging'
require_relative '../interface/z_orders'

module Levels
  class Tilemap < Map
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
    attr_reader :movement_polygons, :events, :enemies

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
        .select {|m| m['name'] =~ /events/i}
        .each   {|m| load_events m}
      layers
        .select {|m| m['name'] =~ /enemies/i}
        .each   {|m| load_enemies m}
    end

    def load_tiles data, z
      arr = []
      enum = data.to_enum
      (0...@height_in_tiles).each do |yi|
        (0...@width_in_tiles).each do |xi|
          index = enum.next
          unless index == 0
            arr << Tile.new(image: @tileset[index - 1], z_order: z, x: xi*@tilewidth, y: yi*@tileheight)
          end
        end
      end
      arr 
    end

    def load_ground layer
      @ground_tiles = load_tiles layer['data'], ZOrder::MAP
    end

    def load_walls layer
      @wall_tiles = load_tiles layer['data'], ZOrder::PLAYER
    end

    def load_movement layer
      @movement_polygons = layer['objects'].collect do |o|
        Polygon.new o['polygon']
      end
    end

    def load_events layer
      @events = layer['objects'].collect do |o|
        Polygon.new o['polygon']
      end
    end

    def load_enemies layer
      @enemies = {}
      layer['objects'].each do |o|
        @enemies[o['type'].downcase.to_sym] ||= []
        @enemies[o['type'].downcase.to_sym] << P[o['x'],o['y']]
      end
    end

    class Tile < Chingu::GameObject
      def rect
        Chingu::Rect.new(x,y, width, height)
      end
    end

    class Polygon
      def initialize list
        @points = list.collect {|p| P[p['x'],p['y']]}
        build_bounding_box
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
