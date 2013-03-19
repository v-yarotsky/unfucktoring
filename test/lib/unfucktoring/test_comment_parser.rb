# encoding: utf-8

require 'test_helper'
require 'unfucktoring/comment_parser'

include Unfucktoring

class TestCommentParser < UnfucktoringTestCase
  def nodes(text)
    CommentParser.new.nodes(text)
  end

  def comment(*children)
    CommentNode.new.tap { |c| c.push *children }
  end

  def quote(author, *children)
    QuoteNode.new(author).tap { |q| q.push *children }
  end

  def text(text)
    TextNode.new(text)
  end

  test "parses correctly when author name is enclosed in single quotes" do
    quote = "[quote='Vladimir']Hello[/quote]"
    expected = comment(
      quote("Vladimir", text("Hello"))
    )
    assert_equal expected, nodes(quote)
  end

  test "parses correctly when author name is enclosed in double quotes" do
    quote = '[quote="Vladimir"]Hello[/quote]'
    expected = comment(
      quote("Vladimir", text("Hello"))
    )
    assert_equal expected, nodes(quote)
  end

  test "parses correctly if author name contains spaces" do
    quote = "[quote='Vladimir Yarotsky']Hello[/quote]"
    expected = comment(
      quote("Vladimir Yarotsky", text("Hello"))
    )
    assert_equal expected, nodes(quote)
  end

  test "parses comments with adjacent quotes" do
    quote = "[quote='Vladimir']Hello[/quote]"
    quote = "[quote='Vladimir']Hello[/quote][quote='Jedi']Goodbye[/quote]"
    expected = comment(
      quote("Vladimir", text("Hello")),
      quote("Jedi", text("Goodbye"))
    )
    assert_equal expected, nodes(quote)
  end

  test "parses comments with nested quotes" do
    quote = "[quote='Vladimir'][quote='Jedi']Goodbye[/quote]Hello[/quote]"
    expected = comment(
      quote(
        "Vladimir",
        quote("Jedi", text("Goodbye")),
        text("Hello")
      )
    )
    assert_equal expected, nodes(quote)
  end

  test "parses comments with 3-level nested quotes" do
    quote = "[quote='Vladimir'][quote='Jedi'][quote='Boo']Stimpack[/quote]Goodbye[/quote]Hello[/quote]"
    expected = comment(
      quote(
        "Vladimir",
        quote(
          "Jedi",
          quote("Boo", text("Stimpack")),
          text("Goodbye")
        ),
        text("Hello")
      )
    )
    assert_equal expected, nodes(quote)
  end

  test "preserves text between quotes" do
    quote = "[quote='Vladimir']Hello[/quote], and [quote='Jedi']Goodbye[/quote]"
    expected = comment(
      quote("Vladimir", text("Hello")),
      text(", and"),
      quote("Jedi", text("Goodbye"))
    )
    assert_equal expected, nodes(quote)
  end

  test "parses trailing text" do
    quote = "[quote='Vladimir Yarotsky']Hello[/quote]Goodbye"
    expected = comment(
      quote("Vladimir Yarotsky", text("Hello")),
      text("Goodbye")
    )
    assert_equal expected, nodes(quote)
  end

  test "parses leading text" do
    quote = "Whee[quote='Vladimir Yarotsky']Hello[/quote]"
    expected = comment(
      text("Whee"),
      quote("Vladimir Yarotsky", text("Hello"))
    )
    assert_equal expected, nodes(quote)
  end
end

