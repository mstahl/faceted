module Faceted

  module Collector

    require 'json'
    require 'active_support/core_ext/hash'

    def self.included(base)
      base.extend ActiveModel::Naming
      base.send(:attr_accessor, :errors)
      base.send(:attr_accessor, :success)
      base.extend ClassMethods
    end

    # Class methods ===========================================================

    module ClassMethods

      def collects(name, args={})
        @collects = eval "#{scope}#{args[:class_name] || name.to_s.classify}"
        define_method :"#{name.downcase}" do
          self.objects
        end
        define_method :finder do
          {"#{args[:find_by]}" => self.send(args[:find_by])}
        end
        self.send(:attr_accessor, args[:find_by])
      end

      def collected_class
        @collects
      end

      def scope
        parent.to_s == "Object" ? "::" : "#{parent.to_s}::"
      end

    end

    # Instance methods =========================================================

    def initialize(args={})
      ! args.empty? && args.symbolize_keys.delete_if{|k,v| v.nil?}.each{|k,v| self.send("#{k}=", v) if self.respond_to?("#{k}=") && ! v.blank? }
      self.errors = []
      self.success = true
    end

    def objects
      return unless self.class.collected_class
      @objects ||= self.class.collected_class.where(self.finder)
    end

    def to_hash
      self.objects.map{|o| o.to_hash}
    end

  end

end