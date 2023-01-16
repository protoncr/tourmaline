module Tourmaline
  abstract class BaseParser
    abstract def parse(text : String) : Tuple(String, Array(Model::MessageEntity))
    abstract def unparse(text : String, entities : Array(Model::MessageEntity)) : String
  end
end
