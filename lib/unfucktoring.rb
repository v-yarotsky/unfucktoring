require 'bundler/setup'

module Unfucktoring
end

$: << File.dirname(__FILE__)

require 'unfucktoring/comment_parser'
require 'unfucktoring/view'

module Unfucktoring
  def self.format_comment(body)
    parser = CommentParser.new
    nodes = parser.nodes(body)
    formatter_visitor = CommentHtmlPrinter.new
    nodes.accept(formatter_visitor)
    formatter_visitor.result
  end
end

