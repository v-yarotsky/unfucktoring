require 'test_helper'
require 'unfucktoring/nodes'

include Unfucktoring

class TestLeafNode < UnfucktoringTestCase
  def leaf
    @leaf ||= Object.new.tap { |obj| obj.extend LeafNode }
  end

  test "leaf cannot have children" do
    leaf.children << :foo
    assert_empty leaf.children
  end

  test "leaf accepts visitor only on itself" do
    visitor = MiniTest::Mock.new
    visitor.expect(:enter, nil, [leaf])
    visitor.expect(:visit, nil, [leaf])
    visitor.expect(:leave, nil, [leaf])

    leaf.accept(visitor)

    visitor.verify
  end

  test "#push returns self" do
    assert_same leaf, leaf.push(:foo)
  end
end

class TestCompositeNode < UnfucktoringTestCase
  def composite
    @leaf ||= Object.new.tap { |obj| obj.extend CompositeNode }
  end

  test "composite can have children" do
    composite.children << :foo
    refute_empty composite.children
  end

  test "composite accepts visitor and passes to children" do
    visitor = MiniTest::Mock.new

    child = composite.clone
    composite.children << child

    visitor.expect(:enter, nil, [composite])
    visitor.expect(:visit, nil, [composite])
    visitor.expect(:enter, nil, [child])
    visitor.expect(:visit, nil, [child])
    visitor.expect(:leave, nil, [child])
    visitor.expect(:leave, nil, [composite])

    composite.accept(visitor)

    visitor.verify
  end

  test "#push adds a children and returns self" do
    assert_same composite, composite.push(:foo)
    assert_includes composite.children, :foo
  end
end

class TestCommentNode < UnfucktoringTestCase
  test "comment is a composite node" do
    assert_kind_of CompositeNode, CommentNode.new
  end

  test "#== is equal if children are equal" do
    comment1 = CommentNode.new.tap { |c| c.children << :foo }
    comment2 = CommentNode.new.tap { |c| c.children << :foo }
    comment3 = CommentNode.new.tap { |c| c.children << :bar }

    assert_equal comment1, comment2
    refute_equal comment1, comment3
  end
end

class TestQuoteNode < UnfucktoringTestCase
  test "quote is a composite node" do
    assert_kind_of CompositeNode, QuoteNode.new("foo")
  end

  test "has author" do
    assert_equal "The Author", QuoteNode.new("The Author").author
  end

  test "#== is equal if author and children are equal" do
    quote1 = QuoteNode.new("Author").tap { |q| q.children << :foo }
    quote2 = QuoteNode.new("Author").tap { |q| q.children << :foo }
    quote3 = QuoteNode.new("Author 2").tap { |q| q.children << :foo }
    quote4 = QuoteNode.new("Author").tap { |q| q.children << :bar }

    assert_equal quote1, quote2
    refute_equal quote1, quote3
    refute_equal quote1, quote4
  end
end

class TestTextNode < UnfucktoringTestCase
  test "text is a leaf node" do
    assert_kind_of LeafNode, TextNode.new("foo")
  end

  test "has text" do
    assert_equal "The Text", TextNode.new("The Text").text
  end

  test "#== is equal if text is equal" do
    text1 = QuoteNode.new("text")
    text2 = QuoteNode.new("text")
    text3 = QuoteNode.new("text 2")

    assert_equal text1, text2
    refute_equal text1, text3
  end
end

