module Mongo::Object
  attr_accessor :_id, :_parent

  def create_object collection, options
    doc = to_mongo

    # Generating custom id if option enabled.
    doc['_id'] = generate_id if Mongo.defaults[:generate_id]

    id = collection.create doc, options
    self._id = id
    id
  end

  def update_object collection, options
    id = _id || "can't update object without _id (#{self})!"
    doc = to_mongo
    collection.update({_id: id}, doc, options)
  end

  def delete_object collection, options
    id = _id || "can't delete object without _id (#{self})!"
    collection.delete({_id: id}, options)
  end

  def save_object collection, options
    if _id
      update_object collection, options
    else
      create_object collection, options
    end
  end

  # Skipping variables starting with @_, usually they
  # have specific meaning and used for things like cache.
  def persistent_instance_variables
    instance_variables.select{|n| n !~ /^@_/}
  end

  # Convert object to document (with nested documents & arrays).
  def to_mongo
    {}.tap do |h|
      # Copy instance variables.
      persistent_instance_variables.each do |iv_name|
        k = iv_name.to_s[1..-1]
        v = instance_variable_get iv_name
        h[k] = v.to_mongo
      end

      # Adding _id & _class.
      h['_id']    = _id if _id
      h['_class'] = self.class.name
    end
  end

  # Override it to generate Your custom ids.
  def generate_id
    generate_random_string_id
  end

  protected
    ID_SYMBOLS = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a
    def generate_random_string_id
      id, size = "", Mongo.defaults[:random_string_id_size]
      size.times{id << ID_SYMBOLS[rand(ID_SYMBOLS.size)]}
      id
    end

  class << self
    def build doc
      doc && _build(doc, nil)
    end

    protected
      def _build doc, parent = nil
        if doc.is_a? Hash
          if class_name = doc[:_class] || doc['_class']
            klass = constantize class_name

            if klass.respond_to? :from_mongo
              obj = klass.from_mongo doc
            else
              obj = klass.new
              parent ||= obj
              doc.each do |k, v|
                next if k.to_sym == :_class

                v = _build v, parent
                obj.instance_variable_set "@#{k}", v
              end
              obj
            end
            obj._parent = parent if parent
            # TODO update it.
            # run_after_callbacks obj, :build
            obj
          else
            {}.tap{|h| doc.each{|k, v| h[k] = _build v, parent}}
          end
        elsif doc.is_a? Array
          doc.collect{|v| _build v, parent}
        else
          # Simple type.
          doc
        end
      end

      def constantize class_name
        @constantize_cache ||= {}
        unless klass = @constantize_cache[class_name]
          klass = eval class_name, TOPLEVEL_BINDING, __FILE__, __LINE__
          @constantize_cache[class_name] = klass
        end
        klass
      end
  end
end