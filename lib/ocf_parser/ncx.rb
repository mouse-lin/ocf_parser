require 'rubygems'
require 'nokogiri'

module OcfParser
  # Holds data in opf file.
  class Ncx

    def initialize(root_path, navPoints, navPointsInFlatten)
      @root_path = root_path
      @navPoints = navPoints
      @navPointsInFlatten = navPointsInFlatten
    end

    def self.parse_ncx(path)
      @xml = Nokogiri::XML::Document.parse(path)
      @flatten_nav_points = [];

      root_path = @xml.search("rootpath").first.text
      first_level_navPoints = @xml.root.at("navMap").children.select{|child| child.name == "navPoint"}

      @first_level_nav_points_count = first_level_navPoints.count

      @first_level_nav_points_order = 0
      navPoints = first_level_navPoints.map { |node| parse_navpoint(node, 1) }

      Ncx.new(root_path, navPoints, @flatten_nav_points) 
    end


    def first_level_nav_points_count
      @first_level_nav_points_count
    end

    def root_path
      @root_path
    end

    def nav_points
      @navPoints
    end

    def flatten_nav_points
      @navPointsInFlatten
    end

    def parse_content(path, content, to_epub=false)
      @navPointsInFlatten.each {
        |navPoint|
        if !navPoint.content_src.nil? && path.end_with?(navPoint.content_src)
          navPoint.parse_content(content, to_epub)
        end
      }

    end

    def self.parse_navpoint(node, level)
      if node.nil?
        return
      end

      navPoint = nil

      if node.attributes['playOrder'].nil?
        navPoint = NavPoint.new(node.at("navLabel/text").text, 
                                node.attributes['id'].value,
                                @first_level_nav_points_order, nil, level)
        @first_level_nav_points_order += 1
      else
        navPoint = NavPoint.new(node.at("navLabel/text").try(:text),
                                node.attributes['id'].value,
                                node.attributes['playOrder'].value,
                                node.search("content").first.attributes['src'].text,
                                level)
      end

      @flatten_nav_points.push(navPoint)

      children = node.children.select {|node| node.name == 'navPoint'}
      navPoint.children = children.map {|child| parse_navpoint(child, level+1)}
      navPoint
    end

  end
end
