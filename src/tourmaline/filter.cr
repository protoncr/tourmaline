module Tourmaline
  abstract class Filter
    abstract def exec(update : Update) : Bool

    def |(other : Filter | FilterGroup)
      FilterGroup.new(self) | other
    end

    def &(other : Filter | FilterGroup)
      FilterGroup.new(self) & other
    end
  end

  class FilterGroup
    @expressions : Array(Tuple(Symbol, Filter | FilterGroup))

    def initialize(base : Filter | FilterGroup)
      @expressions = [] of Tuple(Symbol, Filter | FilterGroup)
      @expressions << { :base, base }
    end

    def exec(update : Update) : Bool
      return true if @expressions.empty?

      if @expressions.size == 1
        return @expressions[0][1].exec(update)
      end

      last = nil
      @expressions.each do |(t, f)|
        case t
        when :base
          last = f
        when :or
          return false unless last.try &.exec(update) || f.exec(update)
        when :and
          return false unless last.try &.exec(update) && f.exec(update)
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
