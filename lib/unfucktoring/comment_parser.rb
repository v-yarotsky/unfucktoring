# encoding: utf-8

require 'unfucktoring/nodes'
require 'unfucktoring/comment_html_printer'

module Unfucktoring

  class CommentParser
    QUOTE_BEGIN = /\[quote=['"](.*)['"]\]$/
    QUOTE_END = /\[\/quote\]$/

    def nodes(text)
      tokens = tokenize(text)
      build_tree(tokens)
    end

    private

    def build_tree(tokens)
      comment = CommentNode.new
      stack = [comment]

      tokens.each do |token|
        case token
        when QUOTE_BEGIN
          quote = QuoteNode.new($1)
          stack.last.children.push quote
          stack.push quote
        when QUOTE_END
          stack.pop
        else
          stack.last.children << TextNode.new(token)
        end
      end

      comment
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
      tokens.reject(&:empty?).map(&:rstrip)
    end
  end

end

