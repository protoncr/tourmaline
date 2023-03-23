module Tourmaline
  class ForumTopicEdited
    include JSON::Serializable

    getter name : String?

    getter icon_custom_emoji_id : String?
  end
end
