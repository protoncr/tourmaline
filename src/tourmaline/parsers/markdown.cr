# module Tourmaline
#   class MarkdownParser < BaseParser
#     def initialize
#       @text = ""
#       @entities = [] of MessageEntity
#       @building_entities = {} of String => MessageEntity
#       @open_tags = Deque(String).new
#       @open_tags_meta = Deque(String?).new
#     end

#     def reset
#       @text = ""
#       @entities = [] of MessageEntity
#       @building_entities = {} of String => MessageEntity
#       @open_tags = Deque(String).new
#       @open_tags_meta = Deque(String?).new
#     end

#     def parse(text str : String) : Tuple(String, Array(MessageEntity))
#       text = Helpers.pad_utf16(str)
#       reader = Char::Reader.new(text)

#       loop do
#         char = reader.current_char

#         if reader.peek_next_char?
#           reader.next_char
#         else
#           break
#         end
#       end
#     end

#     def unparse(text : String, entities : Array(MessageEntity), _offset = 0, _length = nil) : String
#     end
#   end
# end
