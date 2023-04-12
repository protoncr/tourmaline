module Tourmaline
  class Update
    @[JSON::Field(ignore: true)]
    getter update_actions : Array(UpdateAction) { UpdateAction.from_update(self) }

    {% for action in Tourmaline::UpdateAction.constants %}
    def {{ action.id.underscore }}?
      if self.update_actions.includes?(UpdateAction::{{ action.id }})
        true
      else
        false
      end
    end
    {% end %}

    # Returns all users included in this update as a Set
    def users
      users = [] of User?

      [self.channel_post, self.edited_channel_post, self.edited_message, self.message].compact.each do |message|
        if message
          users.concat(message.users)
        end
      end

      if query = self.callback_query
        users << query.from
        if message = query.message
          users.concat(message.users)
        end
      end

      [self.chosen_inline_result, self.shipping_query, self.inline_query, self.pre_checkout_query, self.my_chat_member, self.chat_member].compact.each do |e|
        users << e.from if e.from
      end

      [self.poll_answer].compact.each do |e|
        users << e.user if e.user
      end

      users.compact.uniq!
    end

    # Yields each unique user in this update to the block.
    def users(&block : User ->)
      self.users.each { |u| block.call(u) }
    end

    # Returns all unique chats included in this update
    def chats
      chats = [] of Chat

      [self.channel_post, self.edited_channel_post, self.edited_message, self.message].compact.each do |message|
        chats.concat(message.chats) if message
      end

      [self.callback_query].compact.each do |event|
        if message = event.message
          chats.concat(message.chats)
        end
      end

      [self.my_chat_member, self.chat_member, self.chat_join_request].compact.each do |event|
        chats << event.chat
      end

      chats
    end

    # Yields each unique chat in this update to the block.
    def chats(&block : Chat ->)
      self.chats.each { |c| block.call(c) }
    end
  end
end
