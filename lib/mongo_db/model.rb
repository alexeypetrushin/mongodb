begin
  require 'ruby_ext'
rescue LoadError => e
  warn 'Model requires the ruby_ext gem, please install it'
  raise e
end

require 'mongo_db/object'

module Mongo::Model; end

%w(
  db
  assignment
  callbacks
  validation
  crud
  query
  scope
  misc
  model
).each{|f| require "mongo_db/model/#{f}"}

module Mongo
  module Model
    inherit Db, Assignment, Callbacks, Validation, Crud, Query, Scope, Misc
  end
end