module Tourmaline
  abstract class Middleware
    @continue_iteration : Bool = false

    abstract def call(context : Context)

    def next
      @continue_iteration = true
    end

    def stop
      @continue_iteration = false
    end

    def call_internal(context : Context)
      self.call(context)
      raise Stop.new unless @continue_iteration
    end

    class Stop < Exception; end
  end
end
