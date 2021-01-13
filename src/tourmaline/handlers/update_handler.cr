module Tourmaline
  module Handlers
    class UpdateHandler < EventHandler
      ANNOTATION    = On
      alias Context = Update

      getter action : UpdateAction

      def initialize(action : UpdateAction | String | Symbol, group = :default, priority = 0, &block : Context ->)
        super(group, priority)
        @action = action.is_a?(UpdateAction) ? action : UpdateAction.parse(action.to_s)
        @proc = block
      end

      def call(client : Client, update : Update)
        actions = UpdateAction.from_update(update)
        if @action.in?(actions)
          @proc.call(update)
          true
        end
      end
    end
  end
end
