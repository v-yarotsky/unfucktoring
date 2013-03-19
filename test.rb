# encoding: utf-8

require 'minitest/unit'
require 'minitest/autorun'
require File.expand_path('source.rb')

class TestCommentParser < MiniTest::Unit::TestCase
  def format_quotes(text)
    CommentParser.new.format_quotes!(text, QuoteFormatter.new)
  end

  def tokenize(text)
    CommentParser.new.tokenize(text)
  end

  def self.test(name, &block)
    define_method("test_#{name.gsub(/\s/, "_")}", &block)
  end

  test "converts single quote to html" do
    quote = "[quote='Vladimir']Hello[/quote]"
    assert_equal <<-HTML, format_quotes(quote)
<div class="quotestart">
  <div class="quotename">
    Цитата - Vladimir
  </div>
  <div class="quotecontent">
    Hello
  </div>
</div>
    HTML
  end

  test "converts nested quotes to html" do
    quote = "[quote='Vladimir'][quote='Jedi']Hello[/quote]Goodbye[/quote]"
    assert_equal <<-HTML, format_quotes(quote)
<div class="quotestart">
  <div class="quotename">
    Цитата - Vladimir
  </div>
  <div class="quotecontent">
    <div class="quotestart">
      <div class="quotename">
        Цитата - Jedi
      </div>
      <div class="quotecontent">
        Hello
      </div>
    </div>
    Goodbye
  </div>
</div>
    HTML
  end

  test "converts 3-level nested quotes to html" do
    quote = "[quote='Vladimir'][quote='Jedi'][quote='Boo']Stimpack[/quote]Hello[/quote]Goodbye[/quote]"
    assert_equal <<-HTML, format_quotes(quote)
<div class="quotestart">
  <div class="quotename">
    Цитата - Vladimir
  </div>
  <div class="quotecontent">
    <div class="quotestart">
      <div class="quotename">
        Цитата - Jedi
      </div>
      <div class="quotecontent">
        <div class="quotestart">
          <div class="quotename">
            Цитата - Boo
          </div>
          <div class="quotecontent">
            Stimpack
          </div>
        </div>
        Hello
      </div>
    </div>
    Goodbye
  </div>
</div>
    HTML
  end

  test "converts adjacent quotes to html" do
    quote = "[quote='Vladimir']Hello[/quote][quote='Jedi']Goodbye[/quote]"
    assert_equal <<-HTML, format_quotes(quote)
<div class="quotestart">
  <div class="quotename">
    Цитата - Vladimir
  </div>
  <div class="quotecontent">
    Hello
  </div>
</div>
<div class="quotestart">
  <div class="quotename">
    Цитата - Jedi
  </div>
  <div class="quotecontent">
    Goodbye
  </div>
</div>
    HTML
  end

  test "converts mixed nested and adjacent quotes to html" do
    quote = "[quote='Vladimir'][quote='Boo']Stimpack[/quote]Hello[/quote][quote='Jedi']Goodbye[/quote]"
    assert_equal <<-HTML, format_quotes(quote)
<div class="quotestart">
  <div class="quotename">
    Цитата - Vladimir
  </div>
  <div class="quotecontent">
    <div class="quotestart">
      <div class="quotename">
        Цитата - Boo
      </div>
      <div class="quotecontent">
        Stimpack
      </div>
    </div>
    Hello
  </div>
</div>
<div class="quotestart">
  <div class="quotename">
    Цитата - Jedi
  </div>
  <div class="quotecontent">
    Goodbye
  </div>
</div>
    HTML
  end

  test "preserves arbitrary text" do
    quote = "test1[quote='Vladimir'][quote='Boo']Stimpack[/quote]Hello[/quote][quote='Jedi']Goodbye[/quote]test3"
    assert_equal <<-HTML.rstrip, format_quotes(quote)
test1<div class="quotestart">
  <div class="quotename">
    Цитата - Vladimir
  </div>
  <div class="quotecontent">
    <div class="quotestart">
      <div class="quotename">
        Цитата - Boo
      </div>
      <div class="quotecontent">
        Stimpack
      </div>
    </div>
    Hello
  </div>
</div>
<div class="quotestart">
  <div class="quotename">
    Цитата - Jedi
  </div>
  <div class="quotecontent">
    Goodbye
  </div>
</div>
test3
    HTML
  end

  test "tokenize single quote" do
    quote = "[quote='Vladimir']Hello[/quote]"
    tokens = tokenize(quote)
    assert_equal ["[quote='Vladimir']", "Hello", "[/quote]"], tokens
  end

  test "tokenize adjacent quotes" do
    quote = "[quote='Vladimir']Hello[/quote][quote='Jedi']Goodbye[/quote]"
    tokens = tokenize(quote)
    assert_equal ["[quote='Vladimir']", "Hello", "[/quote]", "[quote='Jedi']", "Goodbye", "[/quote]"], tokens
  end

  test "tokenize nested quotes" do
    quote = "[quote='Vladimir'][quote='Jedi']Goodbye[/quote]Hello[/quote]"
    tokens = tokenize(quote)
    assert_equal ["[quote='Vladimir']", "[quote='Jedi']", "Goodbye", "[/quote]", "Hello", "[/quote]"], tokens
  end

  test "tokenize 3-level nested quotes" do
    quote = "[quote='Vladimir'][quote='Jedi'][quote='Boo']Stimpack[/quote]Goodbye[/quote]Hello[/quote]"
    tokens = tokenize(quote)
    assert_equal ["[quote='Vladimir']", "[quote='Jedi']", "[quote='Boo']", "Stimpack", "[/quote]", "Goodbye", "[/quote]", "Hello", "[/quote]"], tokens
  end

  test "tokenize text between quotes" do
    quote = "[quote='Vladimir']Hello[/quote], and [quote='Jedi']Goodbye[/quote]"
    tokens = tokenize(quote)
    assert_equal ["[quote='Vladimir']", "Hello", "[/quote]", ", and ", "[quote='Jedi']", "Goodbye", "[/quote]"], tokens
  end

  test "tokenize quote beginning with author name in double quotes" do
    quote = '[quote="Vladimir"]Hello[/quote]'
    tokens = tokenize(quote)
    assert_includes tokens, '[quote="Vladimir"]'
  end

  test "tokenize allows space in author name" do
    quote = "[quote='Vladimir Yarotsky']Hello[/quote]"
    tokens = tokenize(quote)
    assert_includes tokens, "[quote='Vladimir Yarotsky']"
  end

  test "tokenize includes trailing text" do
    quote = "[quote='Vladimir Yarotsky']Hello[/quote]Goodbye"
    tokens = tokenize(quote)
    assert_equal "Goodbye", tokens.last
  end

  test "tokenize includes leading text" do
    quote = "Whee[quote='Vladimir Yarotsky']Hello[/quote]"
    tokens = tokenize(quote)
    assert_equal "Whee", tokens.first
  end
end

