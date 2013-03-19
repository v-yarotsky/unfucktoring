# encoding: utf-8

require 'ostruct'
require 'pathname'
require 'bundler/setup'

require 'erubis'
require 'active_support/all'
require 'action_view'

require 'pry'

TEMPLATE_FILE = Pathname.new(File.expand_path('source.html.erb'))
raw_template = File.read(TEMPLATE_FILE)

comment = OpenStruct.new(:body => <<-COMMENT)
Could someone explain this[quote="Respected One"][quote="Megatron"]Vam kaput[/quote]Wat? Why kaput? Who is it?[/quote]Nice sandwitch
COMMENT


class View
  module CommentsHelper
    def format_comment(comment)
      quote_formatter = QuoteFormatter.new
      CommentParser.new.format_quotes!(comment.body, quote_formatter)
    end
  end

  class ViewContext
    include ActionView::Helpers::TextHelper
    include ActionView::Helpers::OutputSafetyHelper
    include CommentsHelper

    def self.with_locals(locals = {})
      Class.new(self) do
        locals.each do |name, value|
          define_method(name) { value }
        end
      end.new
    end

    def binding
      super
    end
  end

  def render(file, locals)
    raw_template = File.read(file)
    template_compiler = Erubis::FastEruby.new(raw_template)
    view_context = ViewContext.with_locals(locals)
    template_compiler.result(view_context.send(:binding))
  end
end

class CommentParser
  QUOTE_BEGIN = /\[quote=['"](.*)['"]\]$/
  QUOTE_END = /\[\/quote\]$/

  def format_quotes!(text, quote_formatter)
    tokens = tokenize(text)
    quotes = []
    current_quote = ""
    text_tokens = []
    result = []

    tokens.each do |token|
      case token
      when QUOTE_BEGIN
        result.push *text_tokens
        text_tokens = []
        quotes << $1
      when QUOTE_END
        quote_author = quotes.pop
        quote_content = text_tokens.join
        new_quote = quote_formatter.format_quote(quote_author, current_quote + quote_content)
        text_tokens = []

        if quotes.empty?
          result << new_quote
          current_quote = ""
        else
          current_quote = new_quote
        end
      else
        text_tokens << token
      end
    end

    result.push current_quote
    result.push *text_tokens
    result.join
  end

  def tokenize(text)
    tokens = []
    buffer = ""

    text.each_char do |c|
      buffer << c

      case buffer
      when QUOTE_BEGIN
        tokens.push *buffer.partition(QUOTE_BEGIN)
        buffer = ""
      when QUOTE_END
        tokens.push *buffer.partition(QUOTE_END)
        buffer = ""
      end
    end
    tokens << buffer
    tokens.reject(&:empty?)
  end
end

class QuoteFormatter
  def format_quote(author, text)
    <<-HTML
<div class="quotestart">
  <div class="quotename">
    Цитата - #{author}
  </div>
  <div class="quotecontent">
#{indent(text)}
  </div>
</div>
    HTML
  end

  private

  def indent(text)
    text.each_line.map { |s| "    #{s}" }.join
  end
end


view = View.new
rendered_template = view.render(TEMPLATE_FILE, :comment => comment)
puts rendered_template
