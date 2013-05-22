require 'nokogiri'

module OcfParser
  class Cover


    def initialize(www_cover)
      @www_cover = www_cover
    end

    def self.parse(io)
      @xml = Nokogiri::XML::Document.parse(io)
      cover = @xml.search("item").find do |item|
        item.attributes["id"].value == "handset" and item.attributes["width"].value == "600"
      end
      www_cover = cover.attributes['herf'].value if cover
      Cover.new(www_cover)
    end


    def www_cover
      @www_cover
    end

  end
end
