require 'crawdad'
require 'crawdad/html_tokenizer'

class ParagraphLinePrinter

  attr_reader :lines, :line_count

  def initialize(paragraph, column_width, font_profiles, options = {})
    @paragraph    = paragraph
    @column_width = column_width
    @font_profiles = font_profiles

    @text = @paragraph.text # Just text for now.

    @index = 0
    @classes = @paragraph['class'].to_s.split(' ')
    @continued = @classes.include?('continued') # Indicates if paragraph has alreay been opened.

    width = options[:width] || 284
    tolorence = options[:tolerence] || 10

    if @continued
      indent = 0
    else
      indent = options[:indent] || 40
    end

    stream = Crawdad::HtmlTokenizer.new(FontProfile2.get('minion', font_profiles_path: options[:font_profiles_path])).paragraph(@text, :hyphenation => true, indent: indent)
    para = Crawdad::Paragraph.new(stream, :width => width)
    @lines = para.lines(tolorence)
    @line_count = @lines.count
  end

  def make_stream(children)
    stream = children.map do |child|
      if child.text?
        child.text.chars
      else
        [
          {
            push: {
              tag_name: child.name,
              attributes: child.attributes
            }
          },
          make_stream(child.children),
          {
            pop: {
              tag_name: child.name
            }
          }
        ]
      end
    end
  end

  def next_character
    i = @index
    while i < @stream_length
      value = @stream[i+=1]
      return value if value.is_a? String
    end
  end

  def print(total_lines_to_print, output)
    lines = []

    while lines.count < total_lines_to_print
      line = get_next_line
      break unless line.present?
      lines << line
    end

    classes = ["typeset"]
    if @continued
      classes << "continued"
    else
      @continued = true
    end

    unless exhasusted?
      classes << "broken"
    end

    if classes.any?
      output.write "<p class=\"#{classes.join(' ')}\">#{lines.join}</p>"
    else
      output.write "<p>#{lines.join}</p>"
    end

    lines.count
  end

  def exhasusted?
    @index >= @lines.count
  end

  def get_next_line
    stringio = StringIO.new

    tokens, breakpoint = @lines[@index]
    stringio.write("<span class=\"line\">")

    # skip over glue and penalties at the beginning of each line
    tokens.shift until Crawdad::Tokens::Box === tokens.first

    tokens.each do |token|
      case token
      when Crawdad::Tokens::Box
        stringio.write(token.content)
      when Crawdad::Tokens::Glue
        stringio.write(" ")
      end
    end
    last_token = tokens.last
    if last_token.class == Crawdad::Tokens::Penalty && last_token[:flagged] == 1
      stringio.write("-")
    end
    stringio.write("</span> ")
    @index += 1
    stringio.string
  rescue => e
    ""
  end

end
