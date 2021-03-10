module RestEasy
  class Mapper

    COPY = Proc.new {|x| x}

    class << self
      attr_accessor :copyings
    end

    def copyings
      self.class.copyings || {}
    end

    def self.copy( from_ish, to_or_proc = nil, maybe_proc = nil, &block )
      @copyings ||= {}

      from = from_ish.to_sym
      to_or_proc_is_proc = to_or_proc.respond_to? :call
      to = to_or_proc_is_proc  ? from : (to_or_proc || from).to_sym
      proc = to_or_proc_is_proc ? to_or_proc : maybe_proc
      callable = proc || block || COPY

      @copyings[ from ] = { to: to, with: callable }
    end

    def initialize(app = nil, args = {})
      @app = app
      @args = args
    end

    def __copy__( attributes, mapped_attributes )
      copyings.each do |from, transform|
        mapped_attributes[ transform[ :to ]] = transform[ :with ].call( attributes[ from ])
      end
      return mapped_attributes
    end

    def __call_mapper__( name, key, attributes, mapped_attributes )
      return mapped_attributes unless self.respond_to? name

      arity = self.method( name ).arity
      case arity
      when 1
        mapped_attributes[ key ] = self.__send__( name, attributes[ key ])
      when 2
        mapped_attributes[ key ] = self.__send__( name, attributes[ key ], attributes )
      when 3
        return self.__send__( name, attributes[ key ], attributes, mapped_attributes )
      end

      return mapped_attributes
    end

    def __call__( attributes = {} )
      mapped_attributes = {}
      mapped_attributes = self.first( attributes ) if self.respond_to? :first
      mapped_attributes = self.__copy__( attributes, mapped_attributes )
      mapped_attributes = attributes.keys.each_with_object( mapped_attributes ) do |key,hash|
        # Skip if it is an unmapped attribute
        has_mapper_for_key = self.respond_to? key
        next hash unless has_mapper_for_key

        mapped_attributes = __call_mapper__( "before_#{key}", key, attributes, mapped_attributes )
        mapped_attributes = __call_mapper__( "#{key}", key, attributes, mapped_attributes )
        mapped_attributes = __call_mapper__( "after_#{key}", key, attributes, mapped_attributes )
      end
      mapped_attributes = self.finally( attributes, mapped_attributes ) if self.respond_to? :finally

      # Call next in middleware chain, or return modified attributes
      if @app and @app.respond_to?( :call )
        @app.call( mapped_attributes )
      else
        return mapped_attributes
      end
    end

    alias call __call__
  end
end
