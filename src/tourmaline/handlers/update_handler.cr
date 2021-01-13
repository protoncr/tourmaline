module Tourmaline
  module Handlers
    class UpdateHandler < EventHandler
      alias Context = Update

      getter action : UpdateAction

      def initialize(@action : UpdateAction, group = :default, priority = 0, &block : Context ->)
        super(group, priority)
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
