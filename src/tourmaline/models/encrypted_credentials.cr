module Tourmaline
  class EncryptedCredentials
    include JSON::Serializable
    include Tourmaline::Model

    getter data : String

    getter hash : String

    getter secret : String
  end
end
