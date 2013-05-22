# -*- coding: utf-8 -*-
require 'spec_helper'
require 'rubygems'
require 'nokogiri'

describe OcfParser::Book do
  before do
    @book = OcfParser::Book.parse_complete(File.open(File.dirname(__FILE__) + '/fixtures/testdata/hou_wang_shu.ocf')) 
  end

  it "should parse the book success" do
    #verify the ncx
    @book.ncx.should_not be_nil
    @book.ncx.nav_points.should_not be_nil


    #verify the medata
    @book.package.should_not be_nil
    @book.package.metadata.should_not be_nil
    @book.package.author.content.should == "\u6731\u5E7C\u68E3"
    @book.package.metadata.format.name.should == "format"
    @book.package.metadata.publisher.content.should == "\u4E2D\u4FE1\u51FA\u7248\u793E"
    @book.package.metadata.isbn.content.should == "9787508630212"
    @book.package.metadata.publisherdate.content.should == "2011-11-01"

    @book.files.each {
      |k, v|
      k.should_not be_empty
    }

    @book.chapters.each {
    
      |k, content|
      p k

      p k.scan(/.+\/(.+)\.(html|htm|xhtml)$/)[0][0]
    }
  end
end
