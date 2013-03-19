module Unfucktoring
  module LeafNode
    def children
      []
    end

    def push(*)
      self
    end
    alias_method :<<, :push

    def accept(visitor)
      visitor.enter(self)
      visitor.visit(self)
      visitor.leave(self)
    end

    def ==(other)
      self.class.equal?(other.class)
    end
  end

  module CompositeNode
    def children
      @children ||= []
    end

    def push(*items)
      children.push *items
      self
    end
    alias_method :<<, :push

    def accept(visitor)
      visitor.enter(self)
      visitor.visit(self)
      children.each do |child|
        child.accept(visitor)
      end
      visitor.leave(self)
    end

    def ==(other)
      self.class.equal?(other.class) && children == other.children
    end
  end

  class CommentNode
    include CompositeNode
  end

  class QuoteNode
    include CompositeNode

    attr_reader :author

    def initialize(author)
      @author = author.dup
    end

    def ==(other)
      super && author == other.author
    end
  end

  class TextNode
    include LeafNode

    attr_reader :text

    def initialize(text)
      @text = text.dup
    end

    def ==(other)
      super && text == other.text
    end
  end
end
