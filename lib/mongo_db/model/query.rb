module Mongo::Model::Query
  module ClassMethods
    def count selector = {}, opts = {}
      collection.count selector, opts
    end

    def first selector = {}, opts = {}
      collection.first selector, opts
    end

    def each selector = {}, opts = {}, &block
      collection.each selector, opts, &block
    end

    def all selector = {}, opts = {}, &block
      if block
        each selector, opts, &block
      else
        list = []
        each(selector, opts){|doc| list << doc}
        list
      end
    end

    def first! selector = {}, opts = {}
      first(selector, opts) || raise(Mongo::NotFound, "document with selector #{selector} not found!")
    end
  end
end