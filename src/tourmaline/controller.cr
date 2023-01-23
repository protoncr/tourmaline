module Tourmaline
  abstract class Controller
    macro inherited
      private CONTROLLER_ACTION_METHODS = [] of {String, String}

      macro method_added(m)
        \{%
           if (m.annotation(TLA::Command) || m.annotation(TLA::CallbackQuery) || m.annotation(TLA::ChosenInlineResult) || m.annotation(TLA::Edited) || m.annotation(TLA::Hears) || m.annotation(TLA::InlineQuery) || m.annotation(TLA::On) || m.annotation(TLA::Catch))
             if CONTROLLER_ACTION_METHODS.includes?({@type.name.id, m.name.id})
               m.raise "A controller action named '##{m.name}' already exists within '#{@type.name}'."
             end

             CONTROLLER_ACTION_METHODS << {@type.name.id, m.name.id}
           end
        %}
      end
    end

    def api
      ADI.container.telegram_telegram_service
    end
  end
end
