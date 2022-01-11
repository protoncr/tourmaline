module Tourmaline
  abstract class BaseParser
    abstract def parse(text : String) : Tuple(String, Array(MessageEntity))
    abstract def unparse(text : String, entities : Array(MessageEntity)) : String
  end
end
