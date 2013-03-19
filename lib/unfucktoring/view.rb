require 'erubis'
require 'active_support/all'
require 'action_view'

module Unfucktoring

  class View
    module CommentsHelper
      def format_comment(comment)
        Unfucktoring.format_comment(comment.body)
      end
    end

    class ViewContext
      include ActionView::Helpers::TextHelper
      include ActionView::Helpers::OutputSafetyHelper
      include CommentsHelper

      def self.with_locals(locals = {})
        Class.new(self) do
          locals.each do |name, value|
            define_method(name) { value }
          end
        end.new
      end

      def binding
        super
      end
    end

    def render(file, locals)
      raw_template = File.read(file)
      template_compiler = Erubis::FastEruby.new(raw_template)
      view_context = ViewContext.with_locals(locals)
      template_compiler.result(view_context.send(:binding))
    end
  end

end

