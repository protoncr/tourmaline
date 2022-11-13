require "openssl/md5"

module Tourmaline
  # The `RoutedMenu` helper class offers a simple to use DSL for creating
  # menus, potentially with multiple levels. Includes support for HTTP
  # like routing, route history, back buttons, and more.
  #
  # Routes are hashed and shortened before being sent, which means you have
  # no need to worry about the typical 65 character callback query data limit.
  #
  # Example:
  # ```
  # MENU = RoutedMenu.build do
  #   route "/" do
  #     content "Some content to go in the home route"
  #     buttons do
  #       route_button "Next page", "/page_2"
  #     end
  #   end
  #
  #   route "/page_2" do
  #     content "..."
  #     buttons do
  #       back_button "Back"
  #     end
  #   end
  # end
  #
  # # in a command
  # send_menu(chat_id, MENU)
  # ```
  class RoutedMenu
    getter routes : Hash(String, Page)
    getter current_route : String
    getter route_history : Array(String)
    getter event_handler : EventHandler

    def initialize(@routes = {} of String => Page,
                   start_route = "/",
                   group = Helpers.random_string(8))
      @current_route = self.class.hash_route(start_route)
      @route_history = [@current_route]
      @event_handler = CallbackQueryHandler.new(/route:(\S+)/) do |ctx|
        handle_button_click(ctx)
      end
    end

    def current_page
      @routes[@current_route]
    end

    def add_route(route, page)
      @routes[self.class.hash_route(route)] = page
    end

    def self.build(starting_route = "/", **options, &block)
      builder = Builder.new
      with builder yield builder
      new(builder.routes, starting_route, **options)
    end

    def self.hash_route(route : String)
      # Hash the route using MD5
      hash = OpenSSL::MD5.hash(route)

      # Shrink the hash so that it + "route:" is no greater than 65 characters
      min_len = Math.min(49, hash.size - 1)
      hash.to_slice[..min_len].hexstring
    end

    def handle_button_click(ctx)
      if (message = ctx.query.message) && (match = ctx.match)
        route = match[1]

        # Check for a back link
        if route.downcase.strip("/") == "back"
          if @route_history.size > 1
            route_history.pop
            route = route_history.pop
          else
            return ctx.query.answer("No page to go back to")
          end
        end

        if page = @routes[route]?
          @current_route = route
          route_history << route
          message.edit_text(page.content,
            reply_markup: page.buttons,
            parse_mode: page.parse_mode || Tourmaline::Client.default_parse_mode,
            disable_link_preview: !page.link_preview)
          ctx.query.answer
        else
          ctx.query.answer("Route not found")
        end
      end
    end

    class Builder
      getter routes : Hash(String, Page)

      def initialize(@routes = {} of String => Page)
      end

      def route(path, &block)
        builder = Page::Builder.new
        with builder yield builder
        hash = RoutedMenu.hash_route(path.to_s)
        @routes[hash] = builder.page
      end
    end

    class Page
      property content : String
      property parse_mode : ParseMode?
      property link_preview : Bool
      property buttons : InlineKeyboardMarkup

      def initialize(@content = "", @buttons = InlineKeyboardMarkup.new, @parse_mode = nil, @link_preview = false)
      end

      class Builder
        getter page : Page

        def initialize
          @page = Page.new
        end

        def content(content)
          @page.content = content.to_s
        end

        def parse_mode(parse_mode : ParseMode)
          @page.parse_mode = parse_mode
        end

        def link_preview(link_preview : Bool)
          @link_preview = link_preview
        end

        def buttons(*args, columns = nil, **options, &block)
          builder = KeyboardBuilder.new(*args, **options)
          with builder yield builder
          page.buttons = builder.keyboard(columns)
        end
      end

      class KeyboardBuilder < InlineKeyboardMarkup::Builder
        def route_button(title, to route)
          callback_button(title.to_s, "route:#{RoutedMenu.hash_route(route)}")
        end

        def back_button(title = "Back")
          callback_button(title.to_s, "route:back")
        end
      end
    end
  end

  class Client
    def send_menu(chat, menu : RoutedMenu, **kwargs)
      chat_id = chat.is_a?(Chat) ? chat.id : chat

      add_event_handler(menu.event_handler) unless event_handlers.includes?(menu.event_handler)

      start_page = menu.current_page

      kwargs = {parse_mode: start_page.parse_mode}.merge(kwargs)
      send_message(chat_id, start_page.content, **kwargs, reply_markup: start_page.buttons)
    end
  end

  class Chat
    def send_menu(menu : RoutedMenu, **kwargs)
      client.send_menu(self, menu, **kwargs)
    end
  end

  class Message
    def reply_with_menu(menu : RoutedMenu, **kwargs)
      client.send_menu(chat, menu, **kwargs, reply_to_message: message_id)
    end

    def respond_with_menu(menu : RoutedMenu, **kwargs)
      client.send_menu(chat, menu, **kwargs, reply_to_message: nil)
    end
  end
end
