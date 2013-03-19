require 'test_helper'
require 'unfucktoring/visitor'

include Unfucktoring

class TestVisitor < UnfucktoringTestCase
  class DummyVisitor < Visitor
    enter(Fixnum) { |s| :enter_fixnum }
    visit(Fixnum) { |s| :visit_fixnum }
    leave(Fixnum) { |s| :leave_fixnum }

    enter(Numeric) { |s| :enter_numeric }
    visit(Numeric) { |s| :visit_numeric }
    leave(Numeric) { |s| :leave_numeric }
  end

  def visitor
    @visitor ||= DummyVisitor.new
  end

  [:enter, :visit, :leave].each do |hook|
    test "defines ##{hook}_* methods" do
      assert_equal :"#{hook}_fixnum", visitor.send("#{hook}", 123)
    end

    test "falls ##{hook}_* back down the inheritance chain" do
      assert_equal :"#{hook}_numeric", visitor.send("#{hook}", 123.0)
    end
  end

  test "does not break if visiting method is not defined" do
    assert_equal nil, visitor.send(:enter, :anything)
  end
end

