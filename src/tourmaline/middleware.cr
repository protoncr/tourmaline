module Tourmaline
  alias MiddlewareProc = Proc(Client, Update, Nil)

  module Middleware
    abstract def call(client : Client, update : Update)

    def next
      raise ContinueIteration.new
    end

    class ContinueIteration < Exception; end

    struct Context
      private abstract struct Param
        abstract def value
      end

      private record Parameter(T) < Param, value : T

      @parameters : Hash(String, Param) = Hash(String, Param).new

      # Returns `true` if a parameter with the provided *name* exists, otherwise `false`.
      def has?(name) : Bool
        @parameters.has_key? name.to_s
      end

      # Returns the value of the parameter with the provided *name* if it exists, otherwise `nil`.
      def get?(name)
        @parameters[name.to_s]?.try &.value
      end

      # Returns the value of the parameter with the provided *name* as a `type` if it exists, otherwise `nil`.
      def get?(name, type : T.class) forall T
        @parameters[name.to_s]?.try &.value.as(T)
      end

      # Returns the value of the parameter with the provided *name*.
      #
      # Raises a `KeyError` if no parameter with that name exists.
      def get(name)
        @parameters.fetch(name.to_s) { raise KeyError.new "No parameter exists with the name '#{name.to_s}'." }.value
      end

      # Returns the value of the parameter with the provided *name* as a `type`.
      def get(name, type : T.class) forall T
        get(name).as(T)
      end

      # Sets a parameter with the provided *name* to *value*.
      def set(name, value : T) : Nil forall T
        self.set name.to_s, value, T
      end

      # Sets a parameter with the provided *name* to *value*, restricted to the given *type*.
      def set(name, value : _, type : T.class) : Nil forall T
        @parameters[name.to_s] = Parameter(T).new value
      end

      # Removes the parameter with the provided *name*.
      def remove(name) : Nil
        @parameters.delete name.to_s
      end
    end
  end
end
