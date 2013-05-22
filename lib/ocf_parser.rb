if !({}.respond_to? 'key')
  class Hash
    def key(x)
      index(x)
    end
  end
end

require 'ocf_parser/version'
require 'ocf_parser/xml_util'
require 'ocf_parser/nav_point'
require 'ocf_parser/ncx'
require 'ocf_parser/meta'
require 'ocf_parser/datemeta'
require 'ocf_parser/metadata'
require 'ocf_parser/manifest'
require 'ocf_parser/package'
require 'ocf_parser/item'
require 'ocf_parser/cover'
require 'ocf_parser/book'
