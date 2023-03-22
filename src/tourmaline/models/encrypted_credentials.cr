module Tourmaline
  class EncryptedCredentials
    include JSON::Serializable

    getter data : String

    getter hash : String

    getter secret : String
  end
end
