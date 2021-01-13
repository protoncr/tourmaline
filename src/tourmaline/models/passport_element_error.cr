module Tourmaline
  class PassportElementError
    include JSON::Serializable
    include Tourmaline::Model

    getter source : String

    getter type : String

    getter message : String

    def initialize(**params)
      {% for prop in @type.instance_variables %}
        @{{ prop.id }} = params[{{ prop.id.symbolize }}]
      {% end %}
    end
  end

  class PassportElementErrorDataField < PassportElementError
    getter field_name : String

    getter data_hash : String
  end

  class PassportElementErrorFrontSide < PassportElementError
    getter file_hash : String
  end

  class PassportElementErrorReverseSide < PassportElementError
    getter file_hash : String
  end

  class PassportElementErrorSelfie < PassportElementError
    getter file_hash : String
  end

  class PassportElementErrorFile < PassportElementError
    getter file_hash : String
  end

  class PassportElementErrorFiles < PassportElementError
    getter file_hashes : Array(String)
  end

  class PassportElementErrorTranslationFile < PassportElementError
    getter file_hash : String
  end

  class PassportElementErrorTranslationFiles < PassportElementError
    getter file_hashes : Array(String)
  end

  class PassportElementErrorUnspecified < PassportElementError
  end
end
