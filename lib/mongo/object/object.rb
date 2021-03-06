module Mongo::Object
  attr_accessor :_id, :_parent, :_saved
  def _id?; !!_id end
  def saved?; _saved end
  def new?; !saved? end

  def id; _id end
  def id= id; self._id = id end
  def id?; _id? end

  def create_object collection, options
    doc = to_mongo

    # Generating custom id if option enabled.
    doc['_id'] ||= generate_id if Mongo.defaults[:generate_id]

    id = collection.create doc, options

    self.id ||= id
    self._saved = true

    id
  end

  def update_object collection, options
    id = self.id || "can't update object without id (#{self})!"
    doc = to_mongo
    collection.update({_id: id}, doc, options)
  end

  def delete_object collection, options
    id = self.id || "can't delete object without id (#{self})!"
    collection.delete({_id: id}, options)
  end

  def save_object collection, options
    if new?
      create_object collection, options
    else
      update_object collection, options
    end
  end

  # Skipping variables starting with @_, usually they
  # have specific meaning and used for things like cache.
  def persistent_instance_variable_names *args
    instance_variables(*args).select{|n| n !~ /^@_/}
  end

  # Convert object to document (with nested documents & arrays).
  def to_mongo
    convert_object self, :_to_mongo
  end

  def _to_mongo options = {}
    h = {}
    # Copy instance variables.
    persistent_instance_variable_names.each do |iv_name|
      k = iv_name.to_s[1..-1]
      v = instance_variable_get iv_name
      h[k] = convert_object v, :_to_mongo
    end

    # Adding _id & _class.
    h['_id']    = id if id
    h['_class'] = self.class.name || \
      raise("unknow class name for model #{h.inspect}!")
    h
  end

  def to_hash
    Hash.respond_to?(:symbolize) ? Hash.symbolize(to_mongo) : to_mongo
  end

  # Override it to generate Your custom ids.
  def generate_id
    generate_random_string_id
  end

  def inspect
    h = to_hash
    h.delete '_class'
    "#<#{self.class}:#{h.inspect}>"
  end
  alias_method :to_s, :inspect

  protected
    def convert_object obj, method, options = {}
      if obj.respond_to? :collect_with_value
        # Array or Hash.
        obj.collect_with_value{|v| convert_object v, method, options}
      elsif obj.respond_to method
        # Object.
        obj.public_send method, options
      else
        # Simple object.
        obj
      end
    end

    ID_SYMBOLS = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a
    def generate_random_string_id
      id, size = "", Mongo.defaults[:random_string_id_size]
      size.times{id << ID_SYMBOLS[rand(ID_SYMBOLS.size)]}
      id
    end

  class << self
    def from_mongo doc
      _from_mongo doc, nil
    end

    def constantize class_name
      @constantize_cache ||= {}
      unless klass = @constantize_cache[class_name]
        klass = eval class_name, TOPLEVEL_BINDING, __FILE__, __LINE__
        @constantize_cache[class_name] = klass
      end
      klass
    end

    protected
      def _from_mongo doc, parent = nil
        if doc.is_a? Hash
          if class_name = doc['_class']
            klass = constantize class_name
            obj = klass.new

            # Only top-level object has _saved attribute.
            obj._saved = true unless parent

            obj._parent = parent if parent

            doc.each do |k, v|
              v = _from_mongo v, obj
              obj.instance_variable_set "@#{k}", v
            end

            obj
          else
            {}.tap{|h| doc.each{|k, v| h[k] = _from_mongo v, parent}}
          end
        elsif doc.is_a? Array
          a = doc.collect{|v| _from_mongo v, parent}
          # Array also can be a model at the same time.
          a._parent = parent if parent and a.respond_to?(:_parent=)
          a
        else
          # Simple type.
          doc
        end
      end
  end
end