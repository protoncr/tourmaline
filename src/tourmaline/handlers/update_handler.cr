module Tourmaline
  module Handlers
    class UpdateHandler < EventHandler
      ANNOTATION = On
      alias Context = Update

      getter actions : Array(UpdateAction)

      def initialize(actions, group = :default, priority = 0, &block : Context ->)
        super(group, priority)
        actions = [actions] unless actions.is_a?(Array)
        @actions = actions.map do |a|
          a.is_a?(UpdateAction) ? a : UpdateAction.parse(a.to_s)
        end
        @proc = block
      end

      def call(client : Client, update : Update)
        actions = UpdateAction.from_update(update)
        @actions.each do |action|
          if action.in?(actions)
            @proc.call(update)
            break
          end
        end
      end
    end
  end
end
