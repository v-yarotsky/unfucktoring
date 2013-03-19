# encoding: utf-8

require 'test_helper'
require 'unfucktoring/comment_html_printer'
require 'ostruct'

include Unfucktoring

class TestCommentHtmlPrinter < UnfucktoringTestCase
  def printer
    @printer ||= CommentHtmlPrinter.new
  end

  comment = OpenStruct.new(:children => [])
  quote = OpenStruct.new(:children => [], :author => "Author")
  text = OpenStruct.new(:children => [], :text => "foo < bar")

  test "enter_CommentNode opens div tag" do
    printer.send "enter_Unfucktoring::CommentNode", comment
    assert_equal %Q{<div class='comment'>}, printer.result
  end

  test "leave_CommentNode closes div tag" do
    printer.send "leave_Unfucktoring::CommentNode", comment
    assert_equal %Q{</div>}, printer.result
  end

  test "enter_TextNode opens p tag and sanitizes text" do
    printer.send "enter_Unfucktoring::TextNode", text
    assert_equal %Q{<p>\n  foo &lt; bar}, printer.result
  end

  test "leave_TextNode closes p tag" do
    printer.send "leave_Unfucktoring::TextNode", text
    assert_equal %Q{</p>}, printer.result
  end

  test "enter_QuoteNode opens div tag" do
    printer.send "enter_Unfucktoring::QuoteNode", quote
    assert_equal <<-HTML.rstrip, printer.result
<div class='quotestart'>
  <div class='quotename'>
    Цитата - Author
  </div>
  <div class='quotecontent'>
    HTML
  end

  test "leave_QuoteNode closes div tag" do
    printer.send "leave_Unfucktoring::QuoteNode", quote
    assert_equal %Q{</div>\n</div>}, printer.result
  end
end

