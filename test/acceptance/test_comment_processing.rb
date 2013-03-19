# encoding: utf-8

require 'test_helper'
require 'unfucktoring'

include Unfucktoring

class TestCommentProcessing < UnfucktoringTestCase
  def format_quotes(text)
    Unfucktoring.format_comment(text)
  end

  test "converts comment with quotes to html" do
    quote = "test1[quote='Vladimir'][quote='Boo']Stimpack[/quote]Hello[/quote][quote='Jedi']Goodbye[/quote]test3"
    assert_equal <<-HTML.rstrip, format_quotes(quote)
<div class='comment'>
  <p>
    test1
  </p>
  <div class='quotestart'>
    <div class='quotename'>
      Цитата - Vladimir
    </div>
    <div class='quotecontent'>
      <div class='quotestart'>
        <div class='quotename'>
          Цитата - Boo
        </div>
        <div class='quotecontent'>
          <p>
            Stimpack
          </p>
        </div>
      </div>
      <p>
        Hello
      </p>
    </div>
  </div>
  <div class='quotestart'>
    <div class='quotename'>
      Цитата - Jedi
    </div>
    <div class='quotecontent'>
      <p>
        Goodbye
      </p>
    </div>
  </div>
  <p>
    test3
  </p>
</div>
    HTML
  end

end

