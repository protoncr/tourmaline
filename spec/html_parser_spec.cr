require "./spec_helper"

include Tourmaline

Spectator.describe "::HTMLParser" do
  let(:parser) { HTMLParser.new }

  it "works when there are entities at the start and end" do
    text = "Hello, world"
    entities = [MessageEntity.new("bold", 0, 5), MessageEntity.new("bold", 7, 5)]
    result = parser.unparse(text, entities)
    expect(result).to eq("<strong>Hello</strong>, <strong>world</strong>")
  end

  it "works even with malformed entities and offsets" do
    text = "🏆Telegram Official Android Challenge is over🏆."
    entities = [MessageEntity.new("text_link", 2, 43, url: "https://example.com")]
    result = parser.unparse(text, entities)
    expect(result).to eq("🏆<a href=\"https://example.com\">Telegram Official Android Challenge is over</a>🏆.")
  end

  it "works with malformed entities with an offset at the end" do
    text = "🏆Telegram Official Android Challenge is over🏆"
    entities = [MessageEntity.new("text_link", 2, 43, url: "https://example.com")]
    result = parser.unparse(text, entities)
    expect(result).to eq("🏆<a href=\"https://example.com\">Telegram Official Android Challenge is over</a>🏆")
  end

  it "works with adjacent entities" do
    original = "<strong>⚙️</strong><em>Settings</em>"
    stripped = "⚙️Settings"

    text, entities = parser.parse(original)
    expect(text).to eq(stripped)
    expect(entities).to eq([MessageEntity.new("bold", 0, 2), MessageEntity.new("italic", 2, 8)])

    text = parser.unparse(text, entities)
    expect(text).to eq(original)
  end

  it "works with an offset at an emoji" do
    text = "Hi\n👉 See example"
    entities = [MessageEntity.new("bold", 0, 2), MessageEntity.new("italic", 3, 2), MessageEntity.new("bold", 10, 7)]
    parsed = "<strong>Hi</strong>\n<em>👉</em> See <strong>example</strong>"

    expect(parser.parse(parsed)).to eq({text, entities})
    expect(parser.unparse(text, entities)).to eq(parsed)
  end

  describe "entities" do
    it "unparses bold" do
      text = "bold"
      entities = [MessageEntity.new("bold", 0, 4)]
      expect(parser.unparse(text, entities)).to eq("<strong>bold</strong>")
    end

    it "unparses italic" do
      text = "italic"
      entities = [MessageEntity.new("italic", 0, 6)]
      expect(parser.unparse(text, entities)).to eq("<em>italic</em>")
    end

    it "unparses underline" do
      text = "underline"
      entities = [MessageEntity.new("underline", 0, 9)]
      expect(parser.unparse(text, entities)).to eq("<u>underline</u>")
    end

    it "unparses strikethrough" do
      text = "strikethrough"
      entities = [MessageEntity.new("strikethrough", 0, 13)]
      expect(parser.unparse(text, entities)).to eq("<del>strikethrough</del>")
    end

    it "unparses code" do
      text = "code"
      entities = [MessageEntity.new("code", 0, 4)]
      expect(parser.unparse(text, entities)).to eq("<code>code</code>")
    end

    it "unparses spoiler" do
      text = "spoiler"
      entities = [MessageEntity.new("spoiler", 0, 7)]
      expect(parser.unparse(text, entities)).to eq("<tg-spoiler>spoiler</tg-spoiler>")
    end

    it "unparses email" do
      text = "johndoe@gmail.com"
      entities = [MessageEntity.new("email", 0, 17)]
      expect(parser.unparse(text, entities)).to eq("<a href=\"mailto:johndoe@gmail.com\">johndoe@gmail.com</a>")
    end

    it "unparses url" do
      text = "https://some-url.xyz"
      entities = [MessageEntity.new("url", 0, 20)]
      expect(parser.unparse(text, entities)).to eq("<a href=\"https://some-url.xyz\">https://some-url.xyz</a>")
    end

    it "unparses text link" do
      text = "some url"
      entities = [MessageEntity.new("text_link", 0, 8, url: "https://some-url.xyz")]
      expect(parser.unparse(text, entities)).to eq("<a href=\"https://some-url.xyz\">some url</a>")
    end

    it "unparses text mention" do
      text = "some user"
      entities = [MessageEntity.new("text_mention", 0, 9, user: User.new(123456789, false, ""))]
      expect(parser.unparse(text, entities)).to eq("<a href=\"tg://user?id=123456789\">some user</a>")
    end
  end
end
