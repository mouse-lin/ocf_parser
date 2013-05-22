# -*- coding: utf-8 -*-
require 'rubygems'
require 'nokogiri'
require 'zip/zip'
require 'fileutils'

# = GEPUB 
# Author:: KOJIMA Satoshi Yincan
# namespace for gepub library.
# GEPUB::Book for parsing/generating, GEPUB::Builder for generating.
# GEPUB::Item holds data of resources like xhtml text, css, scripts, images, videos, etc.
# GEPUB::Meta holds metadata(title, creator, publisher, etc.) with its information (alternate script, display sequence, etc.)

module OcfParser
  class Book
    MIMETYPE='mimetype'
    MIMETYPE_CONTENTS='application/epub+zip'
    CONTAINER='META-INF/container.xml'
    ROOTFILE_PATTERN=/^.+\.opf$/
    CONTAINER_NS='urn:oasis:names:tc:opendocument:xmlns:container'

    def self.rootfile_from_container(rootfile)
      doc = Nokogiri::XML::Document.parse(rootfile)
      ns = doc.root.namespaces
      defaultns = ns.select{ |name, value| value == CONTAINER_NS }.keys[0]
      doc.css("#{defaultns}|rootfiles > #{defaultns}|rootfile")[0]['full-path']
    end

    def self.parse(io)
      files = {}
      package = nil
      package_path = nil
      ncx = nil
      Zip::ZipInputStream::open_buffer(io) {
        |zis|
        while entry = zis.get_next_entry
          if !entry.directory?
            files[entry.name] = zis.read
            case entry.name
              when MIMETYPE then
                if !files[MIMETYPE].start_with?(MIMETYPE_CONTENTS)
                  warn "#{MIMETYPE} is not valid: should be #{MIMETYPE_CONTENTS} but was #{files[MIMETYPE]}"
                end
                files.delete(MIMETYPE)
              when CONTAINER then
                package_path = rootfile_from_container(files[CONTAINER])
                files.delete(CONTAINER)
              when ROOTFILE_PATTERN then
                #package = Package.parse_opf(files[entry.name], entry.name)
                files.delete(entry.name)
              when "META-INF/book.ncx" then
                 ncx = Ncx.parse_ncx(files[entry.name])
                 files.delete(entry.name)
              end
          end
        end

        files.each {
          |k, content|
          if k.end_with? ".html" or k.end_with? ".htm"
            ncx.parse_content(k, content)
          end
        }

        book = Book.new(ncx, package)
        book
      }
    end

    def self.parse_complete(io)
      files = {}
      package = nil
      package_path = nil
      ncx = nil
      cover = nil
      Zip::ZipInputStream::open_buffer(io) {
        |zis|
        while entry = zis.get_next_entry
          if !entry.directory?
            files[entry.name] = zis.read
            case entry.name
              when MIMETYPE then
                if !files[MIMETYPE].start_with?(MIMETYPE_CONTENTS)
                  warn "#{MIMETYPE} is not valid: should be #{MIMETYPE_CONTENTS} but was #{files[MIMETYPE]}"
                end
                files.delete(MIMETYPE)
              when CONTAINER then
                package_path = rootfile_from_container(files[CONTAINER])
              when ROOTFILE_PATTERN then
                package = Package.parse_opf(files[entry.name], entry.name)
              when "META-INF/book.ncx" then
                ncx = Ncx.parse_ncx(files[entry.name])
              when "META-INF/cover.xml" then
                cover = Cover.parse(files[entry.name])
              end
          end
        end

        files.each {
          |k, content|
          if k.end_with? ".html" or k.end_with? ".htm"
            ncx.parse_content(k, content, true)
          end
        }

        book = Book.new(ncx, package, files, cover)
        book
      }
    end

    # creates new empty Book object.
    # usually you do not need to specify any arguments.
    def initialize(ncx, package, files={}, cover=nil)
      @ncx = ncx
      @package = package
      @files = files
      @cover = cover
    end

    def cover
      @cover
    end

    def files
      @files
    end

    def chapters
      @files.select {
        |k, conten|
        k.end_with? ".html" or k.end_with? ".htm" or k.end_with? ".xhtml"
      }
    end

    def ncx
      @ncx
    end

    def package
      @package
    end
  end
end
