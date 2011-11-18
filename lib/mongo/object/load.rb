require 'mongo/object/support'
require 'mongo/object/object'
require 'mongo/object/collection_helper'

Mongo::Collection.class_eval do
  include Mongo::CollectionHelper

  %w(create update save delete).each do |method|
    alias_method "#{method}_without_object", method
    alias_method method, "#{method}_with_object"
  end
end

# By default MongoDB automatically generates BSON::ObjectId,
# it has smaller size than string, but usually strings are more convinient to use.
# This options changes this behaviour and allows to define `generate_id` method
# on model and use it to generate ids.
Mongo.defaults[:generate_id] = false

# Size of autogenerated random string id in default `generate_id` method,
# (used only if :generate_id option if enabled).
Mongo.defaults[:random_string_id_size] = 6