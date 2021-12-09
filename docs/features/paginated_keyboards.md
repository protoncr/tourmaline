### Paginated Keyboards

One common task bot developers face is creating paginated results with back/previous and forward/next buttons. For such situations, [PaginatedKeyboard][Tourmaline::PaginatedKeyboard] is here to save the day!

### PaginatedKeyboard

Creating a paginated keyboard is super easy. Give it the items you want, some formatting options, and inject it into a message. Let's look at an example:

```crystal
@[Command("results")]
def start_command(ctx)
  results = ('a'..'z').to_a.map(&.to_s)

  keyboard = PaginatedKeyboard.new(
    # The results
    results,

    # The number of results to show on each page (default: 10)
    per_page: 5,

    # A string to put before each item (default: nil)
    prefix: "{index}. ",

    # Some text to show above the results (default: nil)
    header: "*Results*",

    # Some text to show below the results (default: nil)
    footer: "\nPage: {page} of {page count}",

    # Text to use for the back button (default: "Back")
    back_text: "Back",

    # Text to use for the next button (default: "Next")
    next_text: "Forward",

    # Used as both the group name and the prefix to the callback query (default: random string)
    id: "results"
  )

  # Send the message by using the keyboard's starting page and the keyboard itself as reply_markup
  ctx.message.respond(keyboard.current_page, parse_mode: :markdown, reply_markup: keyboard)
end
```

Some options have special formatting as well. 

The `prefix` option can include a `{index}` which will be replaced with the (1 indexed) index of the current item.

The `header` and `footer` options can include a `{page}` which returns the current page number, and `{page count}` which returns the total number of pages.