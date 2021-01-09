# Formatting Made Easy

Typing out markdown isn't that hard, and HTML not that much more difficult, but it can be annoying dealing with the interesting quirks around Telegram's parse modes. Most specifically nested entities (which aren't possible with MarkdownV1) and escaping non-entities (especially in MarkdownV2).

For this reason the [Format][Tourmaline::Format] module was created.

## Usage

Every member of the Format module inherits from [Format::Token][Tourmaline::Format::Token], which means each of them include the methods `#to_md(version)` and `#to_html`. This means you can easily use them by themselves if you wish, but the most power comes from using the [Section][Tourmaline::Format::Section] class.

A `Section` is a collection of other tokens. The first token is considered the "header", and the rest will be indented according to the `indent` parameter and then followed by `spacing` newlines. For example:

```crystal
include Tourmaline::Format

message = Section.new(
    Bold.new("This is a heading"),
    "This will be on its own line",
    CodeBlock.new("Here is some code"),
    Group.new("Tourmaline is the ", Bold.new("freaking"), " best!")
)
```

Calling `section.to_md` will then return:

```markdown
*This is a heading*
    This will be on its own line
    ```
    Here is some code
    ```
    Tourmaline is the *freaking* best!
```

The previous example can also be recreated using enumerable like methods:

```crystal
include Tourmaline::Format

message = Section.new
message << Bold.new("This is a heading"),
message << "This will be on its own line",
message << CodeBlock.new("Here is some code"),
message << Group.new("Tourmaline is the ", Bold.new("freaking"), " best!")
```

Or using a "builder" style block:

```crystal
include Tourmaline::Format

message = Section.build do |s|
  s << Bold.new("This is a heading"),
  s << "This will be on its own line",
  s << CodeBlock.new("Here is some code"),
  s << Group.new("Tourmaline is the ", Bold.new("freaking"), " best!")
end
```

For more information on each of the different format types and how to use them, see their individual documentation pages:

{% for typ in crystal.lookup('Tourmaline::Format').types %}
- [{{typ.name}}][{{typ.abs_id}}]
{% endfor %}