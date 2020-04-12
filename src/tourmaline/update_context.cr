module Tourmaline
  class UpdateContext
    # https://github.com/crystal-lang/crystal/blob/052903270710a4d0f11333696fdd455559f19d1e/src/crystal/datum.cr#L33
    Crystal.datum types: {
      bool: Bool,
      i: Int32,
      i64: Int64,
      f: Float32,
      f64: Float64,
      s: String,
      time: Time,
      match_data: Regex::MatchData,
      # message: Message,
      # user: User,
    }, hash_key_type: String, immutable: false

    # Creates an empty `UpdateContext`.
    def initialize
      @raw = Hash(String, UpdateContext).new
    end

    # Creates `UpdateContext` from the given *tuple*.
    def initialize(tuple : NamedTuple)
      @raw = raw = Hash(String, UpdateContext).new
      tuple.each do |key, value|
        raw[key.to_s] = to_context(value)
      end
    end

    # Creates `UpdateContext` from the given *hash*.
    def initialize(hash : Hash(String, V)) forall V
      @raw = raw = Hash(String, UpdateContext).new
      hash.each do |key, value|
        raw[key] = to_context(value)
      end
    end

    # Creates `UpdateContext` from the given *hash*.
    def initialize(hash : Hash(Symbol, V)) forall V
      @raw = raw = Hash(String, UpdateContext).new
      hash.each do |key, value|
        raw[key.to_s] = to_context(value)
      end
    end

    # :nodoc:
    def initialize(ary : Array)
      @raw = ary.map { |e| to_context(e) }
    end

    # Returns a new `UpdateContext` with the keys and values of this context and *other* combined.
    # A value in *other* takes precedence over the one in this context.
    def merge(other : UpdateContext)
      UpdateContext.new(self.as_h.merge(other.as_h).clone)
    end

    # Extends the context with the given values.
    #
    # ```
    # update.context.set a: 1
    # update.context.set b: 2
    # update.info { %q(message with {"a" => 1, "b" => 2} context") }
    # extra = {:c => "3"}
    # update.context.set extra
    # update.info { %q(message with {"a" => 1, "b" => 2, "c" => "3" } context) }
    # extra = {"c" => 3}
    # update.context.set extra
    # update.info { %q(message with {"a" => 1, "b" => 2, "c" => 3 } context) }
    # ```
    def set(**kwargs)
      self.merge(UpdateContext.new(kwargs))
    end

    # :ditto:
    def set(values : Hash(String, V)) forall V
      self.merge(UpdateContext.new(values))
    end

    # :ditto:
    def set(values : NamedTuple)
      self.merge(UpdateContext.new(values))
    end

    private def to_context(value)
      value.is_a?(UpdateContext) ? value : UpdateContext.new(value)
    end
  end
end
