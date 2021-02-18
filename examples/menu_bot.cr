require "../src/tourmaline"
require "../src/tourmaline/extra/routed_menu"

class MenuBot < Tourmaline::Client
  MY_MENU = RoutedMenu.build do
    route "/" do
      content "This is a the root of your menu. Press a button below to continue."
      buttons(columns: 2) do
        route_button "How it works", to: "/how_it_works"
        route_button "Interactive tutorial", to: "/tutorial"
        url_button "Tourmaline website", "https://tourmaline.dev"
      end
    end

    route "/how_it_works" do
      content "Proident sit sint exercitation eiusmod tempor voluptate ex."
      buttons do
        back_button "Back"
      end
    end

    route "/tutorial" do
      content "Culpa anim voluptate officia voluptate laboris eiusmod."
      buttons(columns: 2) do
        route_button "Page 1", to: "/tutorial/page_one"
        route_button "Page 2", to: "/tutorial/page_two"
        back_button "Back"
      end
    end

    route "/tutorial/page_one" do
      content "Anim aliqua pariatur sit reprehenderit est duis."
      buttons do
        back_button "Back"
      end
    end

    route "/tutorial/page_two" do
      content "Deserunt cupidatat qui magna quis eu adipisicing dolor enim duis cillum esse."
      buttons do
        back_button "Back"
      end
    end
  end

  @[Command("start")]
  def start_command(ctx)
    ctx.message.respond_with_menu(MY_MENU)
  end
end

bot = MenuBot.new(bot_token: ENV["API_KEY"])
bot.poll
