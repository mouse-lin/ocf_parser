require 'rubygems'
require 'time'

module OcfParser 
  class DateMeta < Meta
    def initialize(name, content, parent, attributes = {}, refiners = {})
      if content.is_a? String
        p content
        content = Time.parse(content) rescue Time.now
      end
      super(name, content, parent, attributes, refiners)
    end

    def content=(date)
      if content.is_a? String
        content = Time.parse(content)
      end
      @content = content
    end

    def to_s(locale = nil)
      # date type don't have alternate scripts.
      @content.utc.iso8601
    end
  end
end
