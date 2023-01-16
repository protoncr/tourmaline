module Tourmaline::Model
  class ForumTopicCreated
    include JSON::Serializable

    getter name : String

    getter icon_color : Int32

    getter icon_custom_emoji : String?

    def initialize(@name : String, @icon_color : Int32, @icon_custom_emoji : String? = nil)
    end
  end
end
