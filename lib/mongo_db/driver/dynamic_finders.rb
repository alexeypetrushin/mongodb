module Mongo::DynamicFinders
  protected
    #
    # first_by_field, all_by_field, each_by_field, first_by_field
    #
    def method_missing clause, *args, &block
      if clause =~ /^([a-z]_by_[a-z_])|(by_[a-z_])/
        clause = clause.to_s

        bang = clause =~ /!$/
        clause = clause[0..-2] if bang

        finder, field = if clause =~ /^by_/
          ['first', clause.sub(/by_/, '')]
        else
          clause.split(/_by_/, 2)
        end

        finder = 'first' if finder == 'find'
        field = '_id'    if field  == 'id'

        if bang
          raise "You can't use bang version with :#{finder}!" unless finder == 'first'
          finder = "#{finder}!"
        end

        raise "invalid arguments for finder (#{a})!" unless args.size == 1
        field_value = args.first

        send finder.to_sym, {field.to_sym => field_value}, &block
      else
        super
      end
    end
end