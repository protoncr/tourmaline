module Tourmaline
  # The base filter class. A filter is very simple, in that all it
  # needs is an `exec` method, that takes in a `Client` and an
  # `Update` and returns `true` if the update passes, and
  # `false` otherwise.
  #
  # Filters can be combined with other filters using the `#|` and
  # `#&` methods, and in doing so become a `FilterGroup`.
  abstract class Filter
    abstract def exec(client : Client, update : Update) : Bool

    def |(other : Filter | FilterGroup)
      FilterGroup.new(self) | other
    end

    def &(other : Filter | FilterGroup)
      FilterGroup.new(self) & other
    end
  end

  # A combination of multiple `Filter`s.
  class FilterGroup
    @expressions : Array(Tuple(Symbol, Filter | FilterGroup))

    def initialize(base : Filter | FilterGroup)
      @expressions = [] of Tuple(Symbol, Filter | FilterGroup)
      @expressions << { :base, base }
    end

    def exec(client : Client, update : Update) : Bool
      return true if @expressions.empty?

      if @expressions.size == 1
        return @expressions[0][1].exec(client, update)
      end

      last = nil
      @expressions.each do |(t, f)|
        case t
        when :base
          last = f
        when :or
          return false unless last.try &.exec(client, update) || f.exec(client, update)
        when :and
          return false unless last.try &.exec(client, update) && f.exec(client, update)
        else
        end
      end

      true
    end

    def |(other : Filter | FilterGroup)
      @expressions << { :or, other }
      self
    end

    def &(other : Filter | FilterGroup)
      @expressions << { :and, other }
      self
    end

    def to_s(io)
      io << "FilterGroup"
    end
  end
end

require "./filters/*"
