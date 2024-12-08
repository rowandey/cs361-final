#!/usr/bin/env ruby
require 'json'

# Track
# Takes in a list of coordinates and an optional name
class Track
  def initialize(track_coordinates, name=nil)
    @name = name
    @track_coordinates = track_coordinates.map { |c| Coordinates.new(c) }
  end

  # creates JSON for Track
  def get_track_json()
    feature = {
      type: "Feature",
      properties: {},
      geometry: {
        type: "MultiLineString",
        coordinates: []
      }
    }

    if @name != nil
      feature[:properties][:title] = @name
    end

    # adds each track coordinate pair (lat, lon) to the JSON along with elevation if provided
    feature[:geometry][:coordinates] = @track_coordinates.map do |track_c|
      track_c.coordinates.map do |c|
        coords = [c.lon, c.lat]
        if c.ele != nil
          coords << c.ele
        end
        coords

      end
    end

    JSON.generate(feature)
  end

end

# Waypoint
# Takes in latitude, longitude, and as optional paramaters: elevation, name, and icon
class Waypoint
  attr_reader :lat, :lon, :ele, :name, :icon

  def initialize(lon, lat, ele=nil, name=nil, icon=nil)
    @lat = lat
    @lon = lon
    @ele = ele
    @name = name
    @icon = icon
  end

  # creates JSON for Waypoint
  def get_waypoint_json() 
    feature = {
      type: "Feature",
      properties: {},
      geometry: {
        type: "Point",
        coordinates: []
      }
    }

    if @name != nil
      feature[:properties][:title] = @name
    end

    if @icon != nil
      feature[:properties][:icon] = @icon
    end

    feature[:geometry][:coordinates] = [@lon, @lat]

    if @ele != nil
      feature[:geometry][:coordinates] << @ele
    end

    JSON.generate(feature)
  end

end

# World
# takes in name and features of that world
class World
  def initialize(name, features)
    @name = name
    @features = features
  end

  # creates the world
  def to_worldjson()
    worldjson = {
      type:"FeatureCollection",
      features: []
    }

    # goes through each world feature and determines what it is
    @features.each do |f|
      if f.class == Track
        worldjson[:features] << JSON.parse(f.get_track_json)
      elsif f.class == Waypoint
        worldjson[:features] << JSON.parse(f.get_waypoint_json)
      end
    end

    JSON.generate(worldjson)
  end

end

class Coordinates
  attr_reader :coordinates
  def initialize(coordinates)
    @coordinates = coordinates
  end
end

class Point
  attr_reader :lat, :lon, :ele

  def initialize(lon, lat, ele=nil)
    @lon = lon
    @lat = lat
    @ele = ele
  end
end


def main()
  # waypoints
  waypoint = Waypoint.new(-121.5, 45.5, 30, "home", "flag")
  waypoint2 = Waypoint.new(-121.5, 45.6, nil, "store", "dot")

  # track segments
  track_segment_1 = [
  Point.new(-122, 45),
  Point.new(-122, 46),
  Point.new(-121, 46),
  ]

  track_segment_2 = [Point.new(-121, 45), Point.new(-121, 46), ]

  track_segment_3 = [
    Point.new(-121, 45.5),
    Point.new(-122, 45.5),
  ]

  # tracks
  track = Track.new([track_segment_1, track_segment_2], "track 1")
  track2 = Track.new([track_segment_3], "track 2")

  # world gen
  world = World.new("My Data", [waypoint, waypoint2, track, track2])

  puts world.to_worldjson()
end

if File.identical?(__FILE__, $0)
  main()
end