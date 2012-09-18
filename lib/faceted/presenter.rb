module Faceted

  module Presenter

    include Faceted::HasObject

    # Class methods ===========================================================

    def self.included(base)
      base.extend ActiveModel::Naming
      base.extend ClassMethods
      base.extend Faceted::Model::ModelClassMethods
      base.send(:attr_accessor, :id)
      base.send(:attr_accessor, :errors)
      base.send(:attr_accessor, :success)
    end

    module ClassMethods

      def klass
        @presents
      end

      def presents(name, args={})
        class_name = args[:class_name] || name.to_s.classify
        @presents = eval(class_name)
        define_method :"#{class_name.downcase}" do
          object
        end
      end

      def where(args)
        materialize(klass.where(args))
      end

    end

  end

end
