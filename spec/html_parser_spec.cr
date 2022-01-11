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
end
