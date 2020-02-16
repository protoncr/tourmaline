require "../spec_helper"

Spectator.describe Tourmaline::Markup do
  describe ".remove_keyboard" do
    it "should generate remove_keyboard markup" do
      markup = described_class.remove_keyboard(true)
      expect(markup.remove_keyboard).to be_true
    end
  end

  describe ".force_reply" do
    it "should generate force_reply markup" do
      markup = described_class.force_reply(true)
      expect(markup.force_reply).to be_true
    end
  end

  describe ".resize" do
    it "should generate resize markup" do
      markup = described_class.resize(true)
      expect(markup.resize).to be_true
    end
  end

  describe ".one_time" do
    it "should generate one_time markup" do
      markup = described_class.one_time(true)
      expect(markup.one_time).to be_true
    end
  end

  describe ".one_time" do
    it "should generate one_time markup" do
      markup = described_class.one_time(true)
      expect(markup.one_time).to be_true
    end
  end

  describe ".selective" do
    it "should generate selective markup" do
      markup = described_class.selective(true)
      expect(markup.selective).to be_true
    end
  end

  describe ".selective" do
    it "should generate selective markup" do
      markup = described_class.selective(true)
      expect(markup.selective).to be_true
    end
  end

  describe ".keyboard" do
    it "should generate a keyboard markup" do
      markup = described_class.buttons([["one"], ["two", "three"]])
      expected = [
        [Tourmaline::KeyboardButton.new("one")],
        [Tourmaline::KeyboardButton.new("two"), Tourmaline::KeyboardButton.new("three")],
      ]
      expect(markup.keyboard.keyboard.to_json).to eq(expected.to_json)
    end

    it "should generate a keyboard markup with default settings" do
      markup = described_class.buttons([["one", "two", "three"]])
      expected = [[
        Tourmaline::KeyboardButton.new("one"),
        Tourmaline::KeyboardButton.new("two"),
        Tourmaline::KeyboardButton.new("three"),
      ]]
      expect(markup.keyboard.keyboard.to_json).to eq(expected.to_json)
    end
  end
end
