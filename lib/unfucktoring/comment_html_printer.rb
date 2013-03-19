# encoding: utf-8

require 'unfucktoring/visitor'
require 'unfucktoring/nodes'
require 'action_view'

module Unfucktoring

  class CommentHtmlPrinter < Visitor
    include ActionView::Helpers::SanitizeHelper

    def initialize
      @result = []
      @indent_level = 0
      @indent = "  "
    end

    enter CommentNode do |c|
      open_tag %Q{<div class='comment'>}
    end

    leave CommentNode do |c|
      close_tag %Q{</div>}
    end

    enter QuoteNode do |q|
      open_tag %Q{<div class='quotestart'>}
      open_tag %Q{<div class='quotename'>}, sanitize(%Q{Цитата - #{sanitize(q.author)}})
      close_tag %Q{</div>}
      open_tag %Q{<div class='quotecontent'>}
    end

    leave QuoteNode do |q|
      close_tag %Q{</div>}
      close_tag %Q{</div>}
    end

    enter TextNode do |t|
      open_tag %Q{<p>}, sanitize(t.text)
    end

    leave TextNode do |t|
      close_tag %Q{</p>}
    end

    def result
      @result.join("\n")
    end

    private

    def open_tag(tag, content = "")
      @result.push indent(tag)
      increase_indent
      @result.push indent(content) unless content.empty?
    end

    def close_tag(tag_close)
      decrease_indent
      @result.push indent(tag_close)
    end

    def indent(text)
      (@indent * @indent_level) + text
    end

    def increase_indent
      @indent_level += 1
    end

    def decrease_indent
      @indent_level -= 1 if @indent_level > 0
    end
  end

end

