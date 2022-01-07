module Tourmaline
  module Middleware
    @continue_iteration : Bool = false

    abstract def call(client : Client, update : Update)

    def next
      @continue_iteration = true
    end

    def call_internal(client : Client, update : Update)
      self.call(client, update)
      raise StopIteration.new unless @continue_iteration
    end

    class StopIteration < Exception; end

    struct Context
      private abstract struct Param
        abstract def value
      end

      private record Parameter(T) < Param, value : T
      private record LazyParameter(T) < Param, value : Proc(T)

      @parameters : Hash(String, Param) = Hash(String, Param).new

      # Returns `true` if a parameter with the provided *name* exists, otherwise `false`.
      def has?(name) : Bool
        @parameters.has_key?(name.to_s)
      end

      # Returns the value of the parameter with the provided *name* if it exists, otherwise `nil`.
      def get?(name)
        if param = @parameters[name.to_s]?
          result = param.is_a?(LazyParameter) ? param.value.call : param.value
        end
      end

      # Returns the value of the parameter with the provided *name* as a `type` if it exists, otherwise `nil`.
      def get?(name, type : T.class) forall T
        if result = get?(name)
          result.as(T)
        end
      end

      # Returns the value of the parameter with the provided *name*.
      #
      # Raises a `KeyError` if no parameter with that name exists.
      def get(name)
        param = @parameters.fetch(name.to_s) { raise KeyError.new "No parameter exists with the name '#{name.to_s}'." }
        param.is_a?(LazyParameter) ? param.value.call : param.value
      end

      # Returns the value of the parameter with the provided *name* as a `type`.
      def get(name, type : T.class) forall T
        get(name).as(T)
      end

      # Sets a parameter with the provided *name* to *value*.
      def set(name, value : T) : Nil forall T
        self.set(name.to_s, value, T)
      end

      # Sets a lazy parameter with the provided *name* to the return value of the provided *block*.
      def set(name, &block : -> T) : Nil forall T
        self.set(name.to_s, T, &block)
      end

      # Sets a parameter with the provided *name* to *value*, restricted to the given *type*.
      def set(name, value : _, type : T.class) : Nil forall T
        @parameters[name.to_s] = Parameter(T).new value
      end

      # Sets a lazy parameter with the provided *name* to the return value of the provided *block*,
      # restricted to the given *type*.
      def set(name, type : T.class, &block : -> T) : Nil forall T
        @parameters[name.to_s] = LazyParameter(T).new block
      end

      # Removes the parameter with the provided *name*.
      def remove(name) : Nil
        @parameters.delete(name.to_s)
      end
    end
  end
end

require "./middleware/*"
