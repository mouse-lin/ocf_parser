# encoding: utf-8
require 'nokogiri'

module OcfParser
  class NavPoint
    attr_accessor :hierarchy_level, :label, :id, :play_order, :content_src, :children, :html

    def initialize(label, id, play_order, content_src, hierarchy_level, children = [])
      @hierarchy_level = hierarchy_level
      @label = label
      @play_order = play_order
      @content_src = content_src
      @id = id
      @children = children
    end
    def parse_content(content, to_epub=false)
      @index = 1 
      @notes= {}
      @ps = Nokogiri::HTML::Document.parse(content).search("p").map {
         |p|
         parse_inline_note(p.text, to_epub)
       }
    end

    def parse_inline_note(text, to_epub)
      results = text.scan /([^@\[\]]*)@\[([^\[\]]+)\]\((.+?)\)([^@\[\]]*)/

      if results.empty?
        return text
      else
        updated_text = ''
        results.each { |result|
          if to_epub
            anchor = "ref#{@index}"
            text = "(注释#{@index})"
            updated_text += result[0] + result[1] + "<a id='#place#{@index}' href='##{anchor}'>#{text}</a>" + result[3]
            @notes[@index] = result[2]
            @index += 1
          else
            if result[3] && result[3].length > 0
              if is_biaodian(result[3][0])
                result[2] += result[3][0]
                result[3].slice!(0)
              end
            end
            updated_text += result[0] + result[1] + "<span class='inline_note'>#{result[2]}</span>" + result[3]
          end
        }
        return updated_text
      end
    end

  def is_biaodian(char)
    utf8_integer = char.unpack("U").first
    is_biaodian_int(utf8_integer)
  end

  def is_biaodian_int(utf8_integer)
    utf8_integer == 65289 || utf8_integer == 41 || utf8_integer == 8221 || utf8_integer == 8230 || utf8_integer == 65292 || utf8_integer == 12290 || utf8_integer == 65306 || utf8_integer == 65307 || utf8_integer == 12299 || utf8_integer == 12289 || utf8_integer == 65311 || utf8_integer == 65281
  end



    def notes_in_html
      html = ""
      if @notes.size > 0
        @notes.each do |index, content|
          html +=
          <<-EOF
            <div class="fnote">
              <a href="#place#{index}" id="ref#{index}">&lt;注解#{index}&gt;</a>: #{content}
            </div>
          EOF
        end
      end
      html
    end

    def notes
      @notes
    end

    def ps
      if @ps
        return @ps.join("\n\n")
      end
      return ""
    end

    def ps_array
      @ps
    end

    def as_toc_json(id_chapter_mapping)
      {
        :level => @hierarchy_level,
        :title => convert_title(id_chapter_mapping[@id].title),
        :chapter => id_chapter_mapping[@id].id,
        :children => @children.map {|child| child.as_toc_json(id_chapter_mapping) }
      }
    end


    def mobile_manifest(contents)
      content_hash = {}
      content_hash[:target] = @id if contents[@id]
      content_hash[:title] = @label
      content_hash[:id] = @id
      content_hash[:children] = @children.map {|child| child.mobile_manifest(contents)}
      content_hash
    end

    def convert_title(title)
      result = ''
      title.each_char {
        |char|
        utf8_integer = char.unpack("U").first
        if utf8_integer == 8220
          result +=  ["300C".to_i(16)].pack("U")
        elsif utf8_integer == 8221
          result +=  ["300D".to_i(16)].pack("U")
        else
          result += char
        end
      }
      result
    end

  end
end
