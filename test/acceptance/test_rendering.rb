# encoding: utf-8

require 'test_helper'
require 'unfucktoring'
require 'ostruct'

include Unfucktoring

class TestRendering < UnfucktoringTestCase
  test "renders properly" do
    template_file = Pathname.new(File.join(FIXTURES_PATH, 'test.html.erb'))
    raw_template = File.read(template_file)

    comment = OpenStruct.new(:body => <<-COMMENT)
Could someone explain this[quote="Respected One"][quote="Megatron"]Vam kaput[/quote]Wat? Why kaput? Who is it?[/quote]Nice sandwitch
    COMMENT

    view = View.new
    rendered_template = view.render(template_file, :comment => comment)
    expected = <<-HTML
<div class='comment'>
  <p>
    Could someone explain this
  </p>
  <div class='quotestart'>
    <div class='quotename'>
      Цитата - Respected One
    </div>
    <div class='quotecontent'>
      <div class='quotestart'>
        <div class='quotename'>
          Цитата - Megatron
        </div>
        <div class='quotecontent'>
          <p>
            Vam kaput
          </p>
        </div>
      </div>
      <p>
        Wat? Why kaput? Who is it?
      </p>
    </div>
  </div>
  <p>
    Nice sandwitch
  </p>
</div>
    HTML
    assert_equal expected, rendered_template
  end
end

