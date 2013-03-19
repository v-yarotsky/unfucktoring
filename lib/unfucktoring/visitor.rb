module Unfucktoring

  class Visitor
    [:enter, :visit, :leave].each do |hook|
      define_singleton_method hook do |*klasses, &block|
        klasses.each do |klass|
          define_method(:"#{hook}_#{klass.name}", block)
        end
      end

      define_method hook do |obj|
        obj.class.ancestors.each do |ancestor|
          next unless ancestor.name # skip anonymous classes
          method_name = :"#{hook}_#{ancestor.name}"
          next unless respond_to?(method_name)
          return send(method_name, obj)
        end
        nil
      end
    end
  end

end

