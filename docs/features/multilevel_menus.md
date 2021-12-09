# Multilevel Menus

One of the most frustrating, mind numbing, and common tasks with bot development is creating menus using inline keyboards. A typical menu might have multiple options with results spanning multiple levels, and juggling the logic for such menus can easily become a massive pain. Luckily, Tourmaline has you covered with the [RoutedMenu][Tourmaline::RoutedMenu] helper class.

### RoutedMenu

The [RoutedMenu][Tourmaline::RoutedMenu] class provides an easy to use DSL for generating multilevel menus, using standard HTTP routing as inspiration. Let's take a look at a simple menu example:

```crystal
require "tourmaline/extra/routed_menu"

MENU = RoutedMenu.build do
  route "/" do
    content "Some content to go in the home route"
    buttons do
      route_button "Next page", "/page_2"
    end
  end
  
  route "/page_2" do
    content "..."
    buttons do
      back_button "Back"
    end
  end
end
```

Hopefully it's pretty apparent what's happening here. Each "route" is a page which has its own content and buttons. The first page has a single button linking to the `/page_2` route, and the second page has a back button. The `RoutedMenu` maintains a history of visited routes which is used to make the back button work.

One of the nice things about this DSL, besides the obvious syntax improvement, is that it gets rid of the need to keep callback queries under the 65 character limit imposed by Telegram. This is because routes are hashed using MD5 and then truncated so that `route:` + the route name fits within 65 characters.