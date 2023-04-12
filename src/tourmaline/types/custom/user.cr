module Tourmaline
  class User
    def full_name
      [first_name, last_name].compact.join(" ")
    end

    def inline_mention(name)
      name ||= full_name
      "[#{Helpers.escape_md(name)}](tg://user?id=#{id})"
    end
  end
end
